import 'package:flutter/material.dart';

class DoctorColorGenerator {
  static const _palette = <Color>[
    Color(0xFF4F46E5), // indigo
    Color(0xFF0891B2), // cyan
    Color(0xFFD97706), // amber
    Color(0xFFDC2626), // red
    Color(0xFF059669), // emerald
    Color(0xFF7C3AED), // violet
    Color(0xFFDB2777), // pink
    Color(0xFF2563EB), // blue
    Color(0xFFEA580C), // orange
    Color(0xFF16A34A), // green
  ];

  Color getColor(String doctorId) {
    final hash = doctorId.hashCode.abs();
    return _palette[hash % _palette.length];
  }
}
