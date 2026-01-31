import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_strings.dart';
import 'package:silaju/core/constants/app_sizes.dart';
import 'package:silaju/features/report/providers/report_provider.dart';
import 'package:silaju/features/report/models/report_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:silaju/features/report/utils/report_status_helper.dart';

/// Report history screen with filter chips and sorting
class ReportHistoryScreen extends ConsumerStatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  ConsumerState<ReportHistoryScreen> createState() =>
      _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends ConsumerState<ReportHistoryScreen> {
  String _selectedFilter = 'Semua';
  String _sortOrder = 'Terbaru'; // Terbaru, Terlama

  final List<String> _filters = [
    AppStrings.filterAll,
    AppStrings.statusPendingDisplayName,
    AppStrings.statusProcessDisplayName,
    AppStrings.statusVerifiedDisplayName,
    AppStrings.statusDoneDisplayName,
    AppStrings.statusRejectedDisplayName,
  ];
  final List<String> _sortOptions = ['Terbaru', 'Terlama'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportProvider.notifier).fetchUserReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);
    final allReports = reportState.userReports;

    // 1. Filter
    List<Report> filteredReports = allReports.where((report) {
      if (_selectedFilter == AppStrings.filterAll) return true;
      final displayStatus = ReportStatusHelper.getDisplayStatus(report.status);
      return displayStatus == _selectedFilter;
    }).toList();

    // 2. Sort
    filteredReports.sort((a, b) {
      DateTime dateA;
      DateTime dateB;
      try {
        dateA = DateTime.parse(a.createdAt);
      } catch (e) {
        dateA = DateTime.now();
      }
      try {
        dateB = DateTime.parse(b.createdAt);
      } catch (e) {
        dateB = DateTime.now();
      }

      if (_sortOrder == 'Terbaru') {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    // Calculate counts for each filter
    Map<String, int> counts = {};
    for (var filter in _filters) {
      if (filter == AppStrings.filterAll) {
        counts[filter] = allReports.length;
      } else {
        counts[filter] = allReports
            .where(
                (r) => ReportStatusHelper.getDisplayStatus(r.status) == filter)
            .length;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          AppStrings.reportHistory,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppColors.textPrimary),
            onSelected: (value) {
              setState(() {
                _sortOrder = value;
              });
            },
            itemBuilder: (context) {
              return _sortOptions.map((option) {
                return PopupMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      Text(option),
                      if (_sortOrder == option) ...[
                        const Spacer(),
                        const Icon(Icons.check,
                            size: 16, color: AppColors.primaryBlue),
                      ]
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  final count = counts[filter] ?? 0;

                  // Determine color based on filter name
                  Color chipColor = AppColors.primaryBlue;
                  if (filter == AppStrings.statusPendingDisplayName) {
                    chipColor = const Color(0xFFF59E0B);
                  } else if (filter == AppStrings.statusVerifiedDisplayName) {
                    chipColor = const Color(0xFF8B5CF6);
                  } else if (filter == AppStrings.statusProcessDisplayName) {
                    chipColor = const Color(0xFF3B82F6);
                  } else if (filter == AppStrings.statusDoneDisplayName) {
                    chipColor = const Color(0xFF10B981);
                  } else if (filter == AppStrings.statusRejectedDisplayName) {
                    chipColor = AppColors.error;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.sm),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(filter),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: chipColor,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? chipColor : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Report list
          Expanded(
            child: reportState.isLoading && allReports.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(reportProvider.notifier)
                          .fetchUserReports();
                    },
                    child: filteredReports.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text('Tidak ada laporan ditemukan',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSizes.md),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return _buildReportCard(report);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    Color statusColor = ReportStatusHelper.getStatusColor(report.status);
    Color statusBg = ReportStatusHelper.getStatusBackgroundColor(report.status);
    String status = ReportStatusHelper.getDisplayStatus(report.status);

    String formattedDate = report.createdAt;
    try {
      final date = DateTime.parse(report.createdAt);
      formattedDate = DateFormat('d MMM yyyy • HH:mm').format(date);
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        // context.push('/report/${report.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: report.beforeImageUrl != null &&
                        report.beforeImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: report.beforeImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Icon(Icons.image, color: Colors.grey),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.roadName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),

                  // Admin Reason if rejected
                  if (report.adminNotes != null &&
                      report.adminNotes!.isNotEmpty &&
                      status == AppStrings.statusRejectedDisplayName)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Alasan: ${report.adminNotes}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
