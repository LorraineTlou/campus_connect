import 'package:flutter/material.dart';
import '../base/app_colors.dart';
import '../base/app_text_styles.dart';
import '../base/app_constants.dart';

/// Campus Connect — Reusable Button Components
/// Team 2: Core Foundation & UI Standards
///
/// Components:
///   • CCPrimaryButton   — solid indigo, full width by default
///   • CCSecondaryButton — outlined, transparent background
///   • CCTextButton      — no border, text only
///   • CCIconButton      — circular icon button
///   • CCGradientButton  — gradient fill for hero CTAs

// ─────────────────────────────────────────────────────────────────
// 1. Primary Button
// ─────────────────────────────────────────────────────────────────
class CCPrimaryButton extends StatelessWidget {
  const CCPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = AppSpacing.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    )
        : icon != null
        ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon!,
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.button),
      ],
    )
        : Text(label, style: AppTextStyles.button);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 2. Secondary Button (Outlined)
// ─────────────────────────────────────────────────────────────────
class CCSecondaryButton extends StatelessWidget {
  const CCSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = AppSpacing.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: AppColors.primaryLight,
        strokeWidth: 2,
      ),
    )
        : icon != null
        ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon!,
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.button.copyWith(color: AppColors.primaryLight)),
      ],
    )
        : Text(
      label,
      style: AppTextStyles.button.copyWith(color: AppColors.primaryLight),
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 3. Text Button
// ─────────────────────────────────────────────────────────────────
class CCTextButton extends StatelessWidget {
  const CCTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primaryLight,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTextStyles.button.copyWith(color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 4. Circular Icon Button
// ─────────────────────────────────────────────────────────────────
class CCCircleIconButton extends StatelessWidget {
  const CCCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.backgroundColor = AppColors.surface,
    this.iconColor = AppColors.textPrimary,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.avatar,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Icon(icon, color: iconColor, size: size * 0.45),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 5. Gradient Hero Button
// ─────────────────────────────────────────────────────────────────
class CCGradientButton extends StatelessWidget {
  const CCGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.gradient = AppColors.primaryGradient,
    this.height = AppSpacing.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: onPressed == null ? null : gradient,
          color: onPressed == null ? AppColors.textHint : null,
          borderRadius: AppRadius.button,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(label, style: AppTextStyles.button.copyWith(color: Colors.white)),
      ),
    );
  }
}
