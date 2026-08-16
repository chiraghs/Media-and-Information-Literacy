import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sync_queue.dart';

class SyncManager {
  static const String serverUrl = 'http://localhost:8000';
  static final StreamController<bool> _syncStatusController = StreamController<bool>.broadcast();

  // Stream notifying listeners about synchronization progress (e.g. loader badges)
  static Stream<bool> get syncStatusStream => _syncStatusController.stream;

  static void initialize() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Trigger queue synchronization when a connection is established
        processQueue();
      }
    });
  }

  static Future<void> processQueue() async {
    final actions = await SyncQueue.getActions();
    if (actions.isEmpty) return;

    _syncStatusController.add(true); // Sync started

    for (var action in actions) {
      try {
        final headers = {'Content-Type': 'application/json'};
        final uri = Uri.parse('$serverUrl${action.endpoint}');
        
        http.Response response;
        if (action.method == 'POST') {
          response = await http.post(uri, headers: headers, body: jsonEncode(action.payload));
        } else {
          response = await http.get(uri, headers: headers);
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Sync succeeded, remove from queue
          await SyncQueue.removeAction(action.id);
          print("Successfully synchronized action: ${action.endpoint}");
        } else {
          print("Failed sync (Status: ${response.statusCode}) for: ${action.endpoint}");
        }
      } catch (e) {
        print("Server offline or connection interrupted during sync: $e");
        break; // Stop execution if connection is unstable
      }
    }

    _syncStatusController.add(false); // Sync finished
  }
}
