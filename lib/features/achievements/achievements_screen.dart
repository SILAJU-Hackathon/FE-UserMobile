import 'package:flutter/material.dart';
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_strings.dart';
import 'package:silaju/core/constants/app_sizes.dart';

/// Achievements screen with missions and XP card
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _selectedFilter = 'Semua';

  final List<Map<String, dynamic>> _missions = [
    {
      'title': 'Pelapor Aktif',
      'subtitle': 'Kirim 10 laporan',
      'points': 500,
      'status': 'completed',
      'icon': Icons.campaign,
    },
    {
      'title': 'Fotografer Jalanan',
      'subtitle': '30/50 Foto',
      'points': 250,
      'status': 'progress',
      'progress': 0.6,
      'icon': Icons.camera_alt,
    },
    {
      'title': 'Respon Kilat',
      'subtitle': 'Lapor dalam 5 menit',
      'points': 300,
      'status': 'completed',
      'icon': Icons.bolt,
    },
    {
      'title': 'Pahlawan Kota',
      'subtitle': '100 laporan terverifikasi',
      'points': 1000,
      'status': 'locked',
      'icon': Icons.shield,
    },
    {
      'title': 'Penjelajah Wilayah',
      'subtitle': 'Lapor di 5 kecamatan',
      'points': 400,
      'status': 'locked',
      'icon': Icons.explore,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text(AppStrings.achievements),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip(AppStrings.achieved),
                  _buildFilterChip(AppStrings.locked),
                ],
              ),
            ),

            // XP Card
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: _buildXPCard(),
            ),

            // Missions section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.missions,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Update baru saja'),
                  ),
                ],
              ),
            ),

            // Mission list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _missions.length,
              itemBuilder: (context, index) {
                return _buildMissionCard(_missions[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = label);
        },
        selectedColor: AppColors.primaryBlue,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildXPCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.totalPoints,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '2,450 XP',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '12 Didapat',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '8 Terkunci',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.emoji_events,
            size: 80,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final status = mission['status'] as String;
    final isCompleted = status == 'completed';
    final isLocked = status == 'locked';
    final isProgress = status == 'progress';

    Color statusColor;
    String statusText;
    if (isCompleted) {
      statusColor = AppColors.success;
      statusText = AppStrings.completed;
    } else if (isLocked) {
      statusColor = AppColors.textSecondary;
      statusText = AppStrings.locked;
    } else {
      statusColor = AppColors.primaryBlue;
      statusText = '${((mission['progress'] as double) * 100).toInt()}%';
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.border.withOpacity(0.5) : AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isLocked ? AppColors.border : statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked ? Icons.lock : mission['icon'],
              color: isLocked ? AppColors.textSecondary : statusColor,
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mission['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isProgress) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mission['progress'],
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isCompleted)
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
              if (isLocked)
                Icon(Icons.lock, color: AppColors.textSecondary, size: 20),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 14, color: AppColors.xpGold),
                  Text(
                    '+${mission['points']} Poin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isLocked ? AppColors.textSecondary : AppColors.xpGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
