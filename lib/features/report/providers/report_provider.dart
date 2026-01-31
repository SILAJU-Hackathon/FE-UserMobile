import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silaju/core/network/dio_client.dart';
import 'package:silaju/features/report/models/report_model.dart';
import 'package:silaju/features/report/services/report_service.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(DioClient());
});

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.read(reportServiceProvider));
});

class ReportState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ReportState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ReportState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportService _reportService;

  ReportNotifier(this._reportService) : super(ReportState());

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
        throw Exception('Gagal mengirim laporan');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
