import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_strings.dart';
import 'package:silaju/core/constants/app_sizes.dart';
import 'package:silaju/core/router/app_router.dart';
import 'package:silaju/features/auth/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Profile screen with user info, level, stats, and menu
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Helper to format date
    String memberSince = 'Member baru';
    if (user?.createdAt != null) {
      try {
        final date = DateTime.parse(user!.createdAt!);
        memberSince = 'Member sejak ${DateFormat('MMM yyyy').format(date)}';
      } catch (e) {
        memberSince = 'Member sejak -';
      }
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary, // Slightly lighter bg
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.md),
                  // Avatar with Edit Icon
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickImage(context, ref),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: authState.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : (user?.avatar?.isNotEmpty ?? false)
                                      ? CachedNetworkImage(
                                          imageUrl: user!.avatar!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Icon(Icons.person,
                                                  size: 50,
                                                  color: AppColors.primaryBlue),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.person,
                                                  size: 50,
                                                  color: AppColors.primaryBlue),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.primaryBlue,
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Name & Info
                  Text(
                    user?.fullname ?? 'Pengguna',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Belum login',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memberSince,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Edit Profil Button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Level Card with Shadow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: _buildLevelCard(),
            ),
            const SizedBox(height: AppSizes.lg),

            // Statistik Saya
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistik Saya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.description_outlined,
                          value: '24',
                          label: 'Laporan Diterima',
                          color: Colors.blue[50]!,
                          iconColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle_outline,
                          value: '18',
                          label: 'Laporan Selesai',
                          color: Colors.green[50]!,
                          iconColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.emoji_events_outlined,
                          value: '5',
                          label: 'Event Diikuti',
                          color: Colors.purple[50]!,
                          iconColor: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_fire_department_outlined,
                          value: '12',
                          label: 'Hari Streak',
                          color: Colors.orange[50]!,
                          iconColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Achievements
            _buildAchievementsSection(context),
            const SizedBox(height: AppSizes.lg),

            // Menu List
            _buildMenuList(context, ref),

            // Padding for Bottom Navbar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7), // Gold/Yellow bg
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield,
                        color: Color(0xFFD97706), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LEVEL SAYA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHint,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Street Scout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Level 5',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '1,250',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'Poin',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Progress saat ini',
                style: TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
              Text(
                'Target: 2,000',
                style: TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: 200, // Roughly 62% visual
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Text('✨', style: TextStyle(fontSize: 12)),
              SizedBox(width: 4),
              Text(
                '750 poin lagi ke Road Guardian',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11, // Small so it fits
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pencapaian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            children: [
              _buildBadgeItem(Icons.campaign, 'First Report', Colors.blue),
              const SizedBox(width: 16),
              _buildBadgeItem(
                  Icons.camera_alt, 'Pothole Hunter', Colors.orange),
              const SizedBox(width: 16),
              _buildBadgeItem(
                  Icons.volunteer_activism, 'Community Hero', Colors.green),
              const SizedBox(width: 16),
              _buildBadgeItem(Icons.emoji_events, 'Top Reporter', Colors.grey,
                  isLocked: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(IconData icon, String label, Color color,
      {bool isLocked = false}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey[100] : color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: isLocked ? Border.all(color: Colors.grey[300]!) : null,
          ),
          child: Icon(
            icon,
            color: isLocked ? Colors.grey[400] : color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isLocked ? AppColors.textHint : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildMenuItem(
              Icons.manage_accounts_outlined, 'Pengaturan Akun', () {}),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
              Icons.notifications_none_outlined, 'Notifikasi', () {}),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(Icons.help_outline, 'Bantuan', () {}),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            Icons.logout,
            'Logout',
            () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[600]),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        await ref.read(authProvider.notifier).uploadAvatar(pickedFile.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload foto: $e')),
          );
        }
      }
    }
  }
} // End Class
