import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../template/catalog_tab.dart';
import '../template/library_tab.dart';
import '../template/settings_template.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  static const _tabs = [CatalogTab(), LibraryTab(), SettingsTemplate()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: _tabs),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.brown[800],
        unselectedItemColor: Colors.brown[400],
        backgroundColor: Colors.amber[50],
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: l10n.store,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: l10n.library,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
