import 'package:flutter/material.dart';

import '../base/app_colors.dart';
import 'campus_tab_content.dart';
import 'create_post_bottom_sheet.dart';

/// App shell: [Scaffold] + [BottomNavigationBar] for primary navigation.
/// Replace [campusTabContent] bodies with real feature screens as they are built.
class CampusMainShell extends StatefulWidget {
  const CampusMainShell({super.key, this.title = 'Campus Connect'});

  final String title;

  @override
  State<CampusMainShell> createState() => _CampusMainShellState();
}

class _CampusMainShellState extends State<CampusMainShell> {
  int _index = 0;

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Connect',
    ),
    _NavItem(
      icon: Icons.event_outlined,
      activeIcon: Icons.event,
      label: 'Events',
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chat',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  void _showCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? widget.title : _items[_index].label),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        // ↓ context is now passed in so campusTabContent can read Provider
        child: campusTabContent(context, _index, key: ValueKey<int>(_index)),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _showCreatePost,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: AppColors.bottomNavSelected,
        unselectedItemColor: AppColors.bottomNavUnselected,
        items: [
          for (var i = 0; i < _items.length; i++)
            BottomNavigationBarItem(
              icon: Icon(_items[i].icon),
              activeIcon: Icon(
                _items[i].activeIcon,
                color: AppColors.bottomNavSelected,
              ),
              label: _items[i].label,
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
