import 'package:flutter/material.dart';

/// 앱 전역 색상 상수
class AppColors {
  AppColors._();

  // Slate 기반 색상
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // 카테고리 기본 색상
  static const List<Color> categoryColors = [
    Color(0xFF2563EB), // blue
    Color(0xFF16A34A), // green
    Color(0xFFDC2626), // red
    Color(0xFF9333EA), // purple
    Color(0xFFF59E0B), // amber
    Color(0xFF0F766E), // teal
  ];

  // 상태 색상
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
