import 'dart:io';
import 'package:dio/dio.dart';
import 'package:silaju/core/constants/api_endpoints.dart';
import 'package:silaju/core/network/dio_client.dart';
import 'package:silaju/features/report/models/report_model.dart';

class ReportService {
  final DioClient _dioClient;

  ReportService(this._dioClient);

  Future<bool> submitReport(ReportRequest request, File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'json': request.toJson(),
      });

      final response = await _dioClient.dio.post(
        ApiEndpoints.baseUrl + '/api/user/report',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Gagal mengirim laporan: $e');
    }
  }
}
