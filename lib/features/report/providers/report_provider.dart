import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silaju/core/network/dio_client.dart';
import 'package:silaju/features/report/models/report_model.dart';
import 'package:silaju/features/report/services/report_service.dart';

class ReportState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final List<Report> userReports;

  ReportState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.userReports = const [],
  });

  ReportState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    List<Report>? userReports,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error:
          error, // Clear error on new state unless explicitly kept (logic choice)
      isSuccess: isSuccess ?? this.isSuccess,
      userReports: userReports ?? this.userReports,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportService _reportService;

  ReportNotifier(this._reportService) : super(ReportState());

  Future<void> fetchUserReports() async {
    try {
      // Only set loading if no reports yet or specific requirement
      // state = state.copyWith(isLoading: true);
      final reports = await _reportService.getUserReports();
      state = state.copyWith(userReports: reports);
    } catch (e) {
      print('Error fetching reports: $e');
    }
  }

  Future<void> submitReport({
    required File imageFile,
    required double lat,
    required double lng,
    required String description,
    required String roadName,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final request = ReportRequest(
        latitude: lat,
        longitude: lng,
        description: description,
        roadName: roadName,
      );

      final success = await _reportService.submitReport(request, imageFile);

      if (success) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state =
            state.copyWith(isLoading: false, error: 'Gagal mengirim laporan');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void reset() {
    state = ReportState();
  }
}

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  // DioClient is a singleton, so we can just instantiate it or get instance
  final dioClient = DioClient();
  final reportService = ReportService(dioClient);
  return ReportNotifier(reportService);
});
