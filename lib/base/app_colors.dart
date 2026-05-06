import 'package:flutter/material.dart';

class AppColors {

  // Primary Brand Colors
  static const Color primary = Color(0xFF5EC4F2); // Sky Blue
  static const Color primaryLight = Color(0xFF3F51B5); // Lighter Indigo
  static const Color secondary = Color(0xFF5EC4F2); // Sky Blue
  static const Color accent = Color(0xFFF5E100); // Yellow
  static const Color danger = Color(0xFFD62828); // Red

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC); // Soft White
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color card = surface; 
  static const Color surfaceHigher = Color(0xFFF1F5F9); // Lighter Grey Surface
  static const Color black = Color(0xFF111111); // Dark text
  static const Color grey = Color(0xFF64748B); // Light text
  static const Color divider = Color(0xFFE5E7EB);
  static const Color bottomNav = surface;

  // Semantic Text Colors
  static const Color textPrimary = Color(0xFF1E293B); 
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color onSurfaceVariant = Color(0xFF475569);

  // Status Colors
  static const Color success = Color(0xFF8BC34A); // Green
  static const Color successLight = Color(0xFFDCEDC8);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = danger;
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);

  // UI Specific
  static const Color border = Color(0xFFE5E7EB); // Light Grey Border
  static const Color inputFill = Color(0xFFF1F5F9); // Input Background
  static const Color iconInactive = Color(0xFF94A3B8); // Bottom nav inactive icon

  static const Color bottomNavSelected = primary;
  static const Color bottomNavUnselected = iconInactive;

  // Gradients (Optional)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}