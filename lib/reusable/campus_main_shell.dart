import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/create_post_screen.dart';
import '../base/app_colors.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../auth/login_screen.dart';
import 'campus_tab_content.dart';

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
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Feed'),
    _NavItem(
      icon: Icons.add_box_outlined,
      activeIcon: Icons.add_box,
      label: 'Post',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  void _showCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CreatePostScreen(),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await FirebaseAuth.instance.signOut();
      context.read<UserProvider>().clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            // ── Campus Connect Logo/Banner ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Campus Connect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // ── Dark Mode Toggle ──
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          // ── Logout Icon ──
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        // ↓ context is now passed in so campusTabContent can read Provider
        child: campusTabContent(context, _index, key: ValueKey<int>(_index)),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? const Color(0xFF757575) : AppColors.bottomNavUnselected,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        items: [
          for (var i = 0; i < _items.length; i++)
            BottomNavigationBarItem(
              icon: Icon(_items[i].icon),
              activeIcon: Icon(
                _items[i].activeIcon,
                color: AppColors.primary,
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
