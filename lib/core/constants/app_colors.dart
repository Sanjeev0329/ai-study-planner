import 'package:flutter/material.dart';

class AppColors {
  // Brand palette
  static const bgPrimary = Color(0xFF0F172A);
  static const bgSecondary = Color(0xFF1E293B);
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const accentCyan = Color(0xFF22D3EE);
  static const textWhite = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF94A3B8);

  // Glass & glow
  static const glassFill = Color(0x33FFFFFF);
  static const glassBorder = Color(0x24FFFFFF);
  static const glowCyan = Color(0x4022D3EE);
  static const glowPrimary = Color(0x406366F1);

  // Semantic
  static const easy = Color(0xFF34D399);
  static const medium = Color(0xFFFBBF24);
  static const hard = Color(0xFFF87171);
  static const accent = Color(0xFFF472B6);

  // Legacy aliases (used across the app)
  static const bgLight = bgSecondary;
  static const bgDark = bgPrimary;
  static const cardDark = bgSecondary;
  static const textDark = textWhite;
  static const textGrey = textSecondary;
  static const secondary = accentCyan;
}
