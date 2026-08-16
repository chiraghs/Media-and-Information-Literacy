import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../../core/network/sync_queue.dart';
import '../widgets/accessible_button.dart';
import '../widgets/scalable_text.dart';

class SpotCheckView extends StatefulWidget {
  const SpotCheckView({Key? key}) : super(key: key);

  @override
  State<SpotCheckView> createState() => _SpotCheckViewState();
}

class _SpotCheckViewState extends State<SpotCheckView> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  
  int _bias = 0;
  int _clickbait = 0;
  int _sourceVal = 0;
  List<String> _alerts = [];
  bool _hasScanned = false;

  Future<void> _performScan() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _alerts.clear();
    });

    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (isOnline) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8000/api/scan'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'claim_text': text}),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _bias = data['bias_risk'];
            _clickbait = data['clickbait_index'];
            _sourceVal = data['source_validity'];
            final flags = jsonDecode(data['flags_json']) as List;
            _alerts = flags.map((f) => f['text'] as String).toList();
            _hasScanned = true;
          });
        }
      } catch (e) {
        _runLocalHeuristics(text);
      }
    } else {
      // Offline fallback: run local heuristics and queue payload to local database
      _runLocalHeuristics(text);
      await SyncQueue.addAction('/api/scan', 'POST', {'claim_text': text});
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _runLocalHeuristics(String text) {
    int click = 15;
    int biasRisk = 20;
    int src = 80;
    List<String> warnings = [];

    final lower = text.toLowerCase();
    if (lower.contains("shocking") || lower.contains("coverup") || lower.contains("!!!")) {
      click += 25;
      biasRisk += 15;
      warnings.add("Sensationalism: Exclamation points or buzzwords found.");
    }
    if (!RegExp(r'\d+').hasMatch(text)) {
      src -= 30;
      warnings.add("Source validity alert: Statement lacks numeric values or citation dates.");
    }
    if (lower.contains("report") || lower.contains("official") || lower.contains("data")) {
      click -= 10;
      src += 10;
      warnings.add("Factual match: Academic vocabulary verified.");
    }

    setState(() {
      _clickbait = click.clamp(0, 100);
      _bias = biasRisk.clamp(0, 100);
      _sourceVal = src.clamp(0, 100);
      _alerts = warnings.isEmpty ? ["No warnings detected locally."] : warnings;
      _hasScanned = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: ScalableText("SpotCheck Claim Scanner", style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _inputController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Paste claim statement here...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  fillColor: theme.colorScheme.surface,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              AccessibleButton(
                label: _isLoading ? "Scanning..." : "Scan Claim Structure",
                onPressed: _isLoading ? () {} : _performScan,
              ),
              const SizedBox(height: 20),

              if (_hasScanned) ...[
                // Metrics Display
                Card(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScalableText("Audit Results", style: theme.textTheme.titleLarge),
                        const SizedBox(height: 12),
                        _buildMetricRow("Bias Risk Index", "$_bias%", theme),
                        _buildMetricRow("Clickbait Index", "$_clickbait%", theme),
                        _buildMetricRow("Source Validity", "$_sourceVal%", theme),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Warning Flags
                Card(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScalableText("Factual Verification Logs", style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ..._alerts.map((alert) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: theme.colorScheme.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: ScalableText(alert, style: theme.textTheme.bodyLarge)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String val, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ScalableText(label, style: theme.textTheme.bodyLarge),
          ScalableText(
            val,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
