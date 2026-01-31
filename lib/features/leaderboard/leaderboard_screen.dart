import 'package:flutter/material.dart';
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_strings.dart';
import 'package:silaju/core/constants/app_sizes.dart';

/// Leaderboard screen with top 3 podium
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedFilter = 'Bulan Ini';

  final List<Map<String, dynamic>> _topThree = [
    {'name': 'Budi', 'points': 2100, 'rank': 2, 'badge': 'Scout'},
    {'name': 'Ahmad', 'points': 2450, 'rank': 1, 'badge': 'Guardian'},
    {'name': 'Citra', 'points': 1890, 'rank': 3, 'badge': 'Scout'},
  ];

  final List<Map<String, dynamic>> _leaderboard = [
    {'name': 'Dedi', 'points': 1500, 'rank': 4, 'badge': 'Scout'},
    {'name': 'Eka', 'points': 1450, 'rank': 5, 'badge': 'Scout'},
    {'name': 'Fajar', 'points': 1400, 'rank': 6, 'badge': 'Rookie'},
    {'name': 'Gita', 'points': 1350, 'rank': 7, 'badge': 'Rookie'},
    {'name': 'Hendra', 'points': 1300, 'rank': 8, 'badge': 'Rookie'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text(AppStrings.leaderboard),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterChip(AppStrings.thisWeek),
                _buildFilterChip(AppStrings.thisMonth),
                _buildFilterChip(AppStrings.allTime),
              ],
            ),
          ),

          // Top 3 podium
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPodiumItem(_topThree[0], 80), // 2nd
                const SizedBox(width: AppSizes.md),
                _buildPodiumItem(_topThree[1], 100), // 1st
                const SizedBox(width: AppSizes.md),
                _buildPodiumItem(_topThree[2], 60), // 3rd
              ],
            ),
          ),

          // User position card
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: _buildUserPositionCard(),
          ),

          // Leaderboard list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                return _buildLeaderboardItem(_leaderboard[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, double height) {
    final isFirst = user['rank'] == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (isFirst)
          const Icon(Icons.emoji_events, color: AppColors.xpGold, size: 32),

        // Avatar
        Container(
          width: isFirst ? 80 : 64,
          height: isFirst ? 80 : 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isFirst ? AppColors.xpGold : AppColors.white,
              width: 3,
            ),
            color: AppColors.white.withOpacity(0.3),
          ),
          child: Center(
            child: Text(
              user['name'][0],
              style: TextStyle(
                fontSize: isFirst ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          user['name'],
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: isFirst ? 16 : 14,
          ),
        ),

        // Points
        Text(
          '${user['points']} pts',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),

        // Podium block
        Container(
          width: isFirst ? 80 : 64,
          height: height,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '#${user['rank']}',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserPositionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '#15',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.yourPosition,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.levelBadge.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ROOKIE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.levelBadge,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '1,100 pts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '50 poin ke #14',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              '#${user['rank']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user['name'][0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Name and badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: user['badge'] == 'Scout'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.levelBadge.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user['badge'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: user['badge'] == 'Scout'
                          ? AppColors.success
                          : AppColors.levelBadge,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Points
          Text(
            '${user['points']} pts',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
