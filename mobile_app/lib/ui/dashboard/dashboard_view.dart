import 'package:flutter/material.dart';
import '../../core/network/sync_manager.dart';
import '../../core/network/sync_queue.dart';
import '../widgets/accessible_button.dart';
import '../widgets/scalable_text.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const DashboardView({
    Key? key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _points = 0;
  int _pendingSyncCount = 0;
  bool _isSyncing = false;
  bool _simplifiedLayout = false;

  @override
  void initState() {
    super.initState();
    _loadQueueLength();
    SyncManager.syncStatusStream.listen((syncing) {
      if (mounted) {
        setState(() {
          _isSyncing = syncing;
        });
        _loadQueueLength();
      }
    });
  }

  Future<void> _loadQueueLength() async {
    final length = await SyncQueue.getQueueLength();
    if (mounted) {
      setState(() {
        _pendingSyncCount = length;
      });
    }
  }

  void _addMockPoints(int pts) {
    setState(() {
      _points += pts;
    });
    SyncQueue.addAction('/api/register', 'POST', {
      'name': 'Mobile Team Beta',
      'track': 'AI and MIL',
      'modality': 'Applications / Websites',
      'members': [{'name': 'App Developer', 'age': 25}]
    });
    _loadQueueLength();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: ScalableText("MIL Nexus", style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            tooltip: "Toggle Color Theme",
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Semantics(
                header: true,
                child: ScalableText(
                  "Designing the Future of MIL",
                  style: theme.textTheme.displayLarge,
                ),
              ),
              const SizedBox(height: 8),
              ScalableText(
                "UNESCO Youth Initiative 2026",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // MIL Score Card
              Card(
                color: theme.colorScheme.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScalableText("Active MIL Points", style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          ScalableText(
                            "$_points PTS",
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      AccessibleButton(
                        label: "Earn Points",
                        accessibilityHint: "Submits mock team details to database queue",
                        onPressed: () => _addMockPoints(10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Connectivity Sync Card
              Card(
                color: theme.colorScheme.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _pendingSyncCount > 0 ? Icons.cloud_queue : Icons.cloud_done,
                        color: _pendingSyncCount > 0 ? theme.colorScheme.error : theme.colorScheme.secondary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScalableText("Sync Status", style: theme.textTheme.titleLarge),
                            const SizedBox(height: 4),
                            ScalableText(
                              _isSyncing
                                  ? "Synchronizing payloads..."
                                  : "$_pendingSyncCount actions pending offline sync",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (_pendingSyncCount > 0)
                        AccessibleButton(
                          label: "Sync Now",
                          isPrimary: false,
                          onPressed: () => SyncManager.processQueue(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Accessibility Toggles Card
              Card(
                color: theme.colorScheme.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SwitchListTile(
                    title: ScalableText("Simplified Layout", style: theme.textTheme.titleLarge),
                    subtitle: ScalableText("Disable complex graphics to reduce cognitive load", style: theme.textTheme.bodyMedium),
                    value: _simplifiedLayout,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      setState(() {
                        _simplifiedLayout = val;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
