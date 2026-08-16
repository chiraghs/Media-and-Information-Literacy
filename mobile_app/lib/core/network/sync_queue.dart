import 'dart:convert';
import 'package:hive/hive.dart';

class SyncAction {
  final String id;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final int timestamp;

  SyncAction({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'endpoint': endpoint,
      'method': method,
      'payload': jsonEncode(payload),
      'timestamp': timestamp,
    };
  }

  factory SyncAction.fromMap(Map<dynamic, dynamic> map) {
    return SyncAction(
      id: map['id'],
      endpoint: map['endpoint'],
      method: map['method'],
      payload: jsonDecode(map['payload']),
      timestamp: map['timestamp'],
    );
  }
}

class SyncQueue {
  static const String boxName = 'sync_queue_box';

  static Future<void> addAction(String endpoint, String method, Map<String, dynamic> payload) async {
    final box = await Hive.openBox(boxName);
    final action = SyncAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      endpoint: endpoint,
      method: method,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await box.put(action.id, action.toMap());
  }

  static Future<List<SyncAction>> getActions() async {
    final box = await Hive.openBox(boxName);
    return box.values.map((item) => SyncAction.fromMap(item as Map)).toList();
  }

  static Future<void> removeAction(String id) async {
    final box = await Hive.openBox(boxName);
    await box.delete(id);
  }

  static Future<int> getQueueLength() async {
    final box = await Hive.openBox(boxName);
    return box.length;
  }
}
