import 'package:flutter/material.dart';

/// Color palette for SILAJU app based on UI design reference
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF60A5FA);

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundSecondary = Color(0xFFFAFBFC);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textLink = Color(0xFF3B82F6);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Report Status Colors
  static const Color statusSent = Color(0xFF3B82F6); // Dikirim (biru)
  static const Color statusProcess = Color(0xFFF59E0B); // Diproses (kuning)
  static const Color statusComplete = Color(0xFF10B981); // Selesai (hijau)
  static const Color statusRejected = Color(0xFFEF4444); // Ditolak (merah)

  // Gamification Colors
  static const Color xpGold = Color(0xFFFFD700);
  static const Color xpGoldGradientStart = Color(0xFFFBBF24);
  static const Color xpGoldGradientEnd = Color(0xFFF59E0B);
  static const Color levelBadge = Color(0xFF8B5CF6);
  static const Color mintGreen = Color(0xFF6EE7B7);

  // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primaryBlue, primaryBlueDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get goldGradient => const LinearGradient(
        colors: [xpGoldGradientStart, xpGoldGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
