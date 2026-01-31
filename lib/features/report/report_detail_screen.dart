import 'package:flutter/material.dart';
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_sizes.dart';

/// Report detail screen with status timeline
class ReportDetailScreen extends StatelessWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Detail Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  color: AppColors.border,
                  child: const Center(
                    child: Icon(Icons.image,
                        size: 64, color: AppColors.textSecondary),
                  ),
                ),
                Positioned(
                  top: AppSizes.md,
                  right: AppSizes.md,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.statusProcess,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.build, size: 14, color: AppColors.white),
                        SizedBox(width: 4),
                        Text(
                          'Diproses',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Points and ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.xpGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.emoji_events,
                                size: 16, color: AppColors.xpGold),
                            const SizedBox(width: 4),
                            Text(
                              '+10 Poin diterima',
                              style: TextStyle(
                                color: AppColors.xpGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '#JK-00$reportId',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Title
                  const Text(
                    'Jalan Berlubang di Area Sudirman',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Description
                  Text(
                    'Laporan kerusakan jalan yang menyebabkan kemacetan dan bahaya bagi pengendara motor.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Status timeline
                  const Text(
                    'Status Laporan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildTimeline(),
                  const SizedBox(height: AppSizes.lg),

                  // Meta info
                  _buildMetaInfo(),
                  const SizedBox(height: AppSizes.lg),

                  // Location
                  const Text(
                    'Lokasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildLocationCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.warning_amber, color: AppColors.textSecondary),
          label: Text(
            'Laporkan Masalah pada Laporan Ini',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _buildTimelineItem(
          icon: Icons.send,
          title: 'Laporan Dikirim',
          subtitle: '25 Dec 2024, 10:30 WIB',
          isCompleted: true,
          isFirst: true,
        ),
        _buildTimelineItem(
          icon: Icons.verified,
          title: 'Diverifikasi Admin',
          subtitle: '25 Dec 2024, 14:00 WIB',
          isCompleted: true,
        ),
        _buildTimelineItem(
          icon: Icons.build,
          title: 'Sedang Dikerjakan',
          subtitle: 'Tim perbaikan sedang di lokasi',
          isActive: true,
          message: 'Tim sudah sampai di lokasi dan mulai melakukan penambalan.',
        ),
        _buildTimelineItem(
          icon: Icons.check_circle,
          title: 'Selesai',
          subtitle: 'Pending',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
    String? message,
  }) {
    final color = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.primaryBlue
            : AppColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: message != null ? 80 : 40,
                color: isCompleted ? AppColors.success : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      isActive ? AppColors.primaryBlue : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '"$message"',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              SizedBox(height: isLast ? 0 : AppSizes.md),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildMetaItem('Kategori', 'Jalan Raya', Icons.route)),
              Expanded(
                  child: _buildMetaItem('Tingkat', 'Sedang',
                      Icons.warning_amber, AppColors.warning)),
            ],
          ),
          const Divider(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                  child: _buildMetaItem(
                      'Dibuat Oleh', 'Budi Santoso', Icons.person)),
              Expanded(
                  child: _buildMetaItem(
                      'Estimasi', '26 Dec', Icons.calendar_today)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value, IconData icon,
      [Color? iconColor]) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
        const SizedBox(width: AppSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          // Mini map
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusMd),
              ),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 48, color: AppColors.textSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.error),
                    const SizedBox(width: AppSizes.sm),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jl. Jend. Sudirman No. 45',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Karet Tengsin, Tanah Abang, Jakarta Pusat',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('BUKA DI MAPS'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
