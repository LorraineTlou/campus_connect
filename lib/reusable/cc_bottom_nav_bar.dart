import 'package:flutter/material.dart';
import '../base/app_colors.dart';
import '../base/app_text_styles.dart';

/// Campus Connect — Main Bottom Navigation Bar
///
/// Usage in your main Scaffold:
///
///   Scaffold(
///     body: _pages[_currentIndex],
///     bottomNavigationBar: CCBottomNavBar(
///       currentIndex: _currentIndex,
///       onTap: (i) => setState(() => _currentIndex = i),
///     ),
///   )

enum CCNavTab { home, schedule, events, profile, settings }

class CCBottomNavBar extends StatelessWidget {
  const CCBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.notificationCounts = const {},
  });

  /// The currently selected tab index (0–4).
  final int currentIndex;

  /// Called when user taps a nav item.
  final ValueChanged<int> onTap;

  /// Optional badge counts. Key = tab index, value = unread count.
  /// Pass {1: 3} to show a "3" badge on the Schedule tab.
  final Map<int, int> notificationCounts;

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),

    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
    _NavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bottomNav,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              return _CCNavItem(
                item: _items[i],
                isActive: i == currentIndex,
                badgeCount: notificationCounts[i],
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Internal: Individual Nav Item
// ─────────────────────────────────────────────────────────────────
class _CCNavItem extends StatefulWidget {
  const _CCNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  State<_CCNavItem> createState() => _CCNavItemState();
}

class _CCNavItemState extends State<_CCNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final color = isActive ? AppColors.primary : AppColors.textHint;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isActive ? widget.item.activeIcon : widget.item.icon,
                      key: ValueKey(isActive),
                      color: color,
                      size: 24,
                    ),
                  ),
                  if (widget.badgeCount != null && widget.badgeCount! > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: _Badge(count: widget.badgeCount!),
                    ),
                ],
              ),

              const SizedBox(height: 3),

              // Label
              Text(
                widget.item.label,
                style: AppTextStyles.navLabel.copyWith(color: color),
                maxLines: 1,
              ),

              const SizedBox(height: 2),

              // Active dot indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: isActive ? 18 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Internal: Badge Widget
// ─────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Internal: Nav Item Data Model
// ─────────────────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
