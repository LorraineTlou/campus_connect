import 'package:flutter/material.dart';
import '../base/app_colors.dart';
import '../base/app_text_styles.dart';
import '../base/app_constants.dart';

/// Campus Connect — Reusable UI Components
/// Team 2: Core Foundation & UI Standards
///
/// Components:
///   • CCCard          — standard surface card
///   • CCBadge         — status badge / chip
///   • CCAvatar        — user avatar (image or initials)
///   • CCSectionHeader — section title with optional action
///   • CCDivider       — themed divider with optional label
///   • CCEmptyState    — empty/error state illustration placeholder

// ─────────────────────────────────────────────────────────────────
// 1. Card
// ─────────────────────────────────────────────────────────────────
class CCCard extends StatelessWidget {
  const CCCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
    this.backgroundColor = AppColors.surface,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.card;

    return Material(
      color: backgroundColor,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.03),
        child: Container(
          padding: padding ?? AppSpacing.cardInsets,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? AppColors.border,
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 2. Badge
// ─────────────────────────────────────────────────────────────────
enum CCBadgeVariant { primary, success, warning, error, info, neutral }

class CCBadge extends StatelessWidget {
  const CCBadge({
    super.key,
    required this.label,
    this.variant = CCBadgeVariant.primary,
    this.icon,
  });

  final String label;
  final CCBadgeVariant variant;
  final IconData? icon;

  Color get _bg {
    return switch (variant) {
      CCBadgeVariant.primary => AppColors.primary.withValues(alpha: 0.15),
      CCBadgeVariant.success => AppColors.success.withValues(alpha: 0.15),
      CCBadgeVariant.warning => AppColors.warning.withValues(alpha: 0.15),
      CCBadgeVariant.error => AppColors.error.withValues(alpha: 0.15),
      CCBadgeVariant.info => AppColors.info.withValues(alpha: 0.15),
      CCBadgeVariant.neutral => AppColors.textHint.withValues(alpha: 0.15),
    };
  }

  Color get _fg {
    return switch (variant) {
      CCBadgeVariant.primary => AppColors.primaryLight,
      CCBadgeVariant.success => AppColors.successLight,
      CCBadgeVariant.warning => AppColors.warning,
      CCBadgeVariant.error => AppColors.error,
      CCBadgeVariant.info => AppColors.info,
      CCBadgeVariant.neutral => AppColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _bg, borderRadius: AppRadius.badge),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: _fg, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: _fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 3. Avatar
// ─────────────────────────────────────────────────────────────────
class CCAvatar extends StatelessWidget {
  const CCAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40,
    this.backgroundColor = AppColors.primary,
  });

  final String? imageUrl;
  final String? initials;
  final double size;
  final Color backgroundColor;

  String _getInitials() {
    if (initials != null) return initials!.toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor.withValues(alpha: 0.2),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.4),
          width: 1,
        ),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imageUrl == null
          ? Text(
              _getInitials(),
              style: TextStyle(
                fontSize: size * 0.35,
                fontWeight: FontWeight.w600,
                color: backgroundColor,
                height: 1,
              ),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 4. Section Header
// ─────────────────────────────────────────────────────────────────
class CCSectionHeader extends StatelessWidget {
  const CCSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.bodySm),
                ],
              ],
            ),
          ),
          if (action != null && actionLabel != null)
            GestureDetector(
              onTap: action,
              child: Text(
                actionLabel!,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primaryLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 5. Divider with optional label
// ─────────────────────────────────────────────────────────────────
class CCDivider extends StatelessWidget {
  const CCDivider({super.key, this.label, this.verticalPadding = 16});

  final String? label;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: const Divider(color: AppColors.divider, thickness: 0.5),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.divider, thickness: 0.5),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label!, style: AppTextStyles.caption),
          ),
          const Expanded(
            child: Divider(color: AppColors.divider, thickness: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 6. Empty State
// ─────────────────────────────────────────────────────────────────
class CCEmptyState extends StatelessWidget {
  const CCEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.actionLabel,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primaryLight),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl2),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: action,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
