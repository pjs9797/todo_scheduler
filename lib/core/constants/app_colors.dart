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

  // 카테고리 기본 색상 (hex 문자열)
  static const List<String> categoryColors = [
    '#2563EB', // blue
    '#16A34A', // green
    '#DC2626', // red
    '#9333EA', // purple
    '#F59E0B', // amber
    '#0F766E', // teal
  ];

  // Amber 색상 (즐겨찾기용)
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309);

  // 상태 색상
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
