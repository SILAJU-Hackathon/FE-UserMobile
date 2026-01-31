import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_strings.dart';
import 'package:silaju/core/constants/app_sizes.dart';
import 'package:silaju/core/router/app_router.dart';
import 'package:silaju/features/auth/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:silaju/features/report/providers/report_provider.dart';
import 'package:silaju/features/report/utils/report_status_helper.dart';

/// Home screen with dashboard, stats, and recent reports
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch reports when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportProvider.notifier).fetchUserReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final reportState = ref.watch(reportProvider);
    final recentReports = reportState.userReports.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Light gray background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(reportProvider.notifier).fetchUserReports(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header
                _buildHeader(user),

                const SizedBox(height: AppSizes.md),

                // Stats Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: _buildStatsCard(),
                ),

                const SizedBox(height: AppSizes.xl),

                // Quick Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: _buildQuickStats(),
                ),

                const SizedBox(height: AppSizes.xl),

                // Report Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: _buildReportButton(context),
                ),

                const SizedBox(height: AppSizes.xl),

                // Recent Reports
                _buildRecentReports(context, recentReports),

                const SizedBox(height: 100), // Bottom padding for FAB/Nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    // Assuming user is UserData type, but passed as dynamic or var to avoid import issues if not explicit
    // Using user?.fullname etc.
    final name = user?.fullname ?? 'Pengguna';
    final avatarUrl = user?.avatar;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD1E4FA), // Fallback color
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue),
                          errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue),
                        )
                      : const Icon(Icons.person, color: AppColors.primaryBlue),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Online green
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.md),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppStrings.greeting},',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                Text(
                  'Halo, $name!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Notification icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 24),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue, // Fallback
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Level & Shield
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Level 4',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Street Scout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1,250',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  Text(
                    'Poin',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700), // Gold
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFB45309), // Dark gold text
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menuju Road Guardian',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                '70%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: const Color(0xFF1E40AF).withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(
                  Color(0xFFFFD700)), // Gold/Yellow
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 16),

          // Rank
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Color(0xFFFFD700), size: 16),
              const SizedBox(width: 6),
              const Text(
                'Rank #15 di Surabaya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatItem(
          '12',
          'Total',
          Icons.list_alt,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          '8',
          'Verified',
          Icons.check_circle_outline,
          const Color(0xFF10B981),
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          '2',
          'Proses',
          Icons.people_alt_outlined,
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.createReport),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB), // Primary Blue
          borderRadius: BorderRadius.circular(100), // Pill shape
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Lapor Jalan Rusak',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports(BuildContext context, List<dynamic> reports) {
    if (reports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child:
                Text('Belum ada laporan', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Laporan Terakhir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.reportHistory),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return _buildReportCard(context, reports[index]);
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, dynamic report) {
    // Dynamic because report might be Map or Report object.
    // Assuming Report object based on new flow, but handling gracefully.

    final title = report is Map ? report['title'] : report.roadName;
    final desc = report is Map ? report['desc'] : report.description;
    final time =
        report is Map ? report['time'] : report.createdAt; // Format time later
    final rawStatus = report is Map ? report['status'] : report.status;
    final image = report is Map ? report['image'] : report.beforeImageUrl;

    Color statusColor = ReportStatusHelper.getStatusColor(rawStatus.toString());
    Color statusBg =
        ReportStatusHelper.getStatusBackgroundColor(rawStatus.toString());
    String statusDisplay =
        ReportStatusHelper.getDisplayStatus(rawStatus.toString());

    // Date formatting
    String timeAgo = 'Baru saja';
    if (time is String && time.isNotEmpty) {
      try {
        final date = DateTime.parse(time);
        final diff = DateTime.now().difference(date);
        if (diff.inDays > 0) {
          timeAgo = '${diff.inDays} hari lalu';
        } else if (diff.inHours > 0) {
          timeAgo = '${diff.inHours} jam lalu';
        } else if (diff.inMinutes > 0) {
          timeAgo = '${diff.inMinutes} menit lalu';
        }
      } catch (e) {
        // ignore
      }
    }

    return GestureDetector(
      onTap: () {
        // context.push('/report/${report.id}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 8,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: image != null && image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                        placeholder: (context, url) =>
                            const Icon(Icons.image, color: Colors.grey),
                      )
                    : const Icon(Icons.image, color: Colors.grey, size: 30),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusDisplay,
                          style: TextStyle(
                            color: statusColor.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
