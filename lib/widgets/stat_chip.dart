import 'package:flutter/material.dart';

/// Small stat pill used in the profile header (Posts / Followers / Following).
class StatChip extends StatelessWidget {
  final String label;
  final int value;

  const StatChip({super.key, required this.label, required this.value});

  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textLight = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _format(value),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: _textLight)),
      ],
    );
  }

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}
