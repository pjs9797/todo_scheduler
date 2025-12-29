import 'package:flutter/material.dart';

/// 색상 관련 유틸리티 함수
class ColorUtils {
  ColorUtils._();

  /// Hex 문자열을 Color로 변환
  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Color를 Hex 문자열로 변환
  static String colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  /// 색상을 투명도가 적용된 배경색으로 변환
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// 색상에 맞는 텍스트 색상 반환 (밝은 배경 -> 어두운 텍스트)
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
