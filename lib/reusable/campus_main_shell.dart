import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../screens/create_post_screen.dart';
import '../base/app_colors.dart';
import '../providers/theme_provider.dart';
import 'campus_tab_content.dart';

/// App shell: [Scaffold] + [BottomNavigationBar] for primary navigation.
class CampusMainShell extends StatefulWidget {
  const CampusMainShell({super.key, this.title = 'Campus Connect'});

  final String title;

  @override
  State<CampusMainShell> createState() => _CampusMainShellState();
}

class _CampusMainShellState extends State<CampusMainShell> {
  int _index = 0;

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Feed'),
    _NavItem(icon: Icons.add_box_outlined, activeIcon: Icons.add_box, label: 'Post'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  void showCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CreatePostScreen(),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? widget.title : _items[_index].label),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          // ── Dark / Light mode toggle ──────────────────────────────────────
          Tooltip(
            message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    RotationTransition(turns: anim, child: FadeTransition(opacity: anim, child: child)),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey<bool>(isDark),
                  color: colorScheme.onSurface,
                ),
              ),
              onPressed: () => themeProvider.toggle(),
            ),
          ),
          // ── Logout ───────────────────────────────────────────────────────
          Tooltip(
            message: 'Sign Out',
            child: IconButton(
              icon: Icon(Icons.logout_rounded, color: colorScheme.onSurface),
              onPressed: _handleLogout,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: campusTabContent(context, _index, key: ValueKey<int>(_index)),
      ),

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
              activeIcon: Icon(_items[i].activeIcon, color: AppColors.bottomNavSelected),
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
