import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/sync_manager.dart';
import 'core/themes/editorial_theme.dart';
import 'ui/dashboard/dashboard_view.dart';
import 'ui/spotcheck/spotcheck_view.dart';
import 'ui/truthcraft/truthcraft_view.dart';
import 'ui/initiative_info/initiative_info_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive offline persistence database
  await Hive.initFlutter();
  
  // Start background sync listeners
  SyncManager.initialize();
  
  runApp(const MilNexusApp());
}

class MilNexusApp extends StatefulWidget {
  const MilNexusApp({Key? key}) : super(key: key);

  @override
  State<MilNexusApp> createState() => _MilNexusAppState();
}

class _MilNexusAppState extends State<MilNexusApp> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIL Nexus',
      theme: EditorialTheme.lightTheme,
      darkTheme: EditorialTheme.darkTheme,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: MainNavigationScaffold(
        onToggleTheme: _toggleTheme,
        isDarkTheme: _isDarkTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const MainNavigationScaffold({
    Key? key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      DashboardView(
        onToggleTheme: widget.onToggleTheme,
        isDarkTheme: widget.isDarkTheme,
      ),
      const SpotCheckView(),
      const TruthCraftView(),
      const InitiativeInfoView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Semantics(
        label: "Bottom Navigation Menu",
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.5),
          backgroundColor: theme.colorScheme.surface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Hub',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check),
              label: 'SpotCheck',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset_outlined),
              activeIcon: Icon(Icons.videogame_asset),
              label: 'TruthCraft',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }
}
