import 'package:flutter/material.dart';

/// Consistent padding and gap values for the design system.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: md, vertical: md);
}
