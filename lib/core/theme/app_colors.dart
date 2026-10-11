import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF0F766E); // Deep Teal
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color secondary = Color(0xFF4F46E5); // Indigo
  static const Color accent = Color(0xFF0EA5E9); // Sky

  // Metric specific colors
  static const Color steps = Color(0xFF10B981); // Emerald
  static const Color stepsContainer = Color(0xFFD1FAE5);
  static const Color calories = Color(0xFFF59E0B); // Amber / Orange
  static const Color caloriesContainer = Color(0xFFFEF3C7);
  static const Color sleep = Color(0xFF6366F1); // Indigo / Violet
  static const Color sleepContainer = Color(0xFFE0E7FF);

  // Sleep stage specific colors
  static const Color deepSleep = Color(0xFF312E81); // Midnight indigo
  static const Color remSleep = Color(0xFF6366F1); // Indigo
  static const Color lightSleep = Color(0xFF93C5FD); // Light sky
  static const Color awake = Color(0xFFFCA5A5); // Soft red / alert

  // Neutral / Backgrounds (Light)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Neutral / Backgrounds (Dark)
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkCardBorder = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color success = Color(0xFF10B981);
}
