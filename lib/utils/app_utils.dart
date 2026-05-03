import 'package:flutter/material.dart';

/// Campus Connect — Utility Helpers
/// Team 2: Core Foundation & UI Standards
///
/// Categories:
///   • Validators      — form field validation functions
///   • Formatters      — date/time/text formatting
///   • Extensions      — convenience extensions on core types
///   • AppUtils        — misc static helpers

// ─────────────────────────────────────────────────────────────────
// 1. Validators
// ─────────────────────────────────────────────────────────────────
class Validators {
  Validators._();

  /// Returns null if valid, or an error message string.

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Add at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Add at least one number';
    return null;
  }

  static String? studentId(String? value) {
    if (value == null || value.trim().isEmpty) return 'Student ID is required';
    final regex = RegExp(r'^\d{6,12}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid Student ID (6–12 digits)';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional by default
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    if (!RegExp(r'^\d{9,15}$').hasMatch(cleaned)) return 'Enter a valid phone number';
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'This field'} must be at most $max characters';
    }
    return null;
  }

  /// Chain multiple validators — returns the first error found.
  static String? compose(String? value, List<String? Function(String?)> validators) {
    for (final v in validators) {
      final result = v(value);
      if (result != null) return result;
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────
// 2. Formatters
// ─────────────────────────────────────────────────────────────────
class AppFormatters {
  AppFormatters._();

  /// "09:00 AM"
  static String time(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// "Mon, Apr 25"
  static String shortDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  /// "Monday, April 25 2026"
  static String fullDate(DateTime dt) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day} ${dt.year}';
  }

  /// "2 hours ago" / "just now" / "in 3 days"
  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative) {
      final pos = diff.abs();
      if (pos.inMinutes < 60) return 'in ${pos.inMinutes} min';
      if (pos.inHours < 24) return 'in ${pos.inHours}h';
      return 'in ${pos.inDays} days';
    }
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return shortDate(dt);
  }

  /// "3.87" GPA with exactly 2 decimal places
  static String gpa(double value) => value.toStringAsFixed(2);

  /// Truncate long strings: "Campus Eng..." (maxLength includes ellipsis)
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Initials from full name: "Tawanda Moyo" → "TM"
  static String initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────
// 3. Extensions
// ─────────────────────────────────────────────────────────────────
extension StringExtensions on String {
  String get capitalised => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  String get titleCase => split(' ').map((w) => w.capitalised).join(' ');
  bool get isValidEmail => RegExp(r'^[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  String initials() => AppFormatters.initials(this);
}

extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  String get timeString => AppFormatters.time(this);
  String get shortDateString => AppFormatters.shortDate(this);
  String get relativeString => AppFormatters.relativeTime(this);
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get statusBarHeight => MediaQuery.of(this).padding.top;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) {
    return showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 4. Misc App Utilities
// ─────────────────────────────────────────────────────────────────
class AppUtils {
  AppUtils._();

  /// Debounce helper — prevents rapid re-firing (e.g. search on type)
  static void Function() debounce(VoidCallback fn, Duration delay) {
    dynamic timer;
    return () {
      timer?.cancel();
      timer = Future.delayed(delay, fn);
    };
  }

  /// Returns true if two date ranges overlap
  static bool datesOverlap(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    return s1.isBefore(e2) && s2.isBefore(e1);
  }
}
