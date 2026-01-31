import 'package:flutter/material.dart';
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_strings.dart';

class ReportStatusHelper {
  ReportStatusHelper._();

  static String getDisplayStatus(String status) {
    if (status.isEmpty) return '-';

    final s = status.toLowerCase();

    if (s == 'pending') {
      return AppStrings.statusPendingDisplayName;
    } else if (s == 'complete') {
      return AppStrings.statusVerifiedDisplayName;
    } else if (s == 'assigned') {
      return AppStrings.statusProcessDisplayName;
    } else if (s == 'finish by worker' || s == 'verified' || s == 'selesai') {
      return AppStrings.statusDoneDisplayName;
    } else if (s == 'rejected' || s == 'ditolak') {
      return AppStrings.statusRejectedDisplayName;
    }

    // Default fallback (capitalize first letter)
    return status[0].toUpperCase() + status.substring(1);
  }

  static Color getStatusColor(String status) {
    final s = status.toLowerCase();

    if (s == 'pending') {
      return const Color(0xFFF59E0B); // Amber
    } else if (s == 'complete') {
      return const Color(0xFF8B5CF6); // Violet/Purple for Verified
    } else if (s == 'assigned') {
      return const Color(0xFF3B82F6); // Blue
    } else if (s == 'finish by worker' || s == 'verified' || s == 'selesai') {
      return const Color(0xFF10B981); // Emerald/Green
    } else if (s == 'rejected' || s == 'ditolak') {
      return AppColors.error;
    }

    return Colors.grey;
  }

  static Color getStatusBackgroundColor(String status) {
    final s = status.toLowerCase();

    if (s == 'pending') {
      return const Color(0xFFFEF3C7); // Amber 100
    } else if (s == 'complete') {
      return const Color(0xFFEDE9FE); // Violet 100
    } else if (s == 'assigned') {
      return const Color(0xFFDBEAFE); // Blue 100
    } else if (s == 'finish by worker' || s == 'verified' || s == 'selesai') {
      return const Color(0xFFD1FAE5); // Emerald 100
    } else if (s == 'rejected' || s == 'ditolak') {
      return AppColors.error.withOpacity(0.1);
    }

    return Colors.grey.withOpacity(0.1);
  }
}
