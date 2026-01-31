import 'package:dio/dio.dart';
import 'package:silaju/core/constants/api_endpoints.dart';
import 'package:silaju/core/network/dio_client.dart';
import 'package:silaju/features/auth/models/auth_models.dart';

/// Authentication service for login and register
class AuthService {
  final DioClient _dioClient = DioClient();

  /// Login user
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw ApiErrorResponse.fromJson(response.data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email atau password salah');
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Register new user
  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // Registration successful
        return;
      } else if (response.statusCode == 400) {
        final error = ApiErrorResponse.fromJson(response.data);
        throw Exception(error.message);
      } else {
        throw Exception('Registrasi gagal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null) {
          final error = ApiErrorResponse.fromJson(errorData);
          throw Exception(error.message);
        }
        throw Exception('Data registrasi tidak valid');
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Sign in with Google
  Future<GoogleAuthResponse> signInWithGoogle(String idToken) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.googleAuth,
        data: GoogleAuthRequest(idToken: idToken).toJson(),
      );

      print(
          'DEBUG: response.data from Google Auth: ${response.data}'); // Add this debug line
      if (response.statusCode == 200) {
        return GoogleAuthResponse.fromJson(response.data);
      } else {
        throw Exception('Google Sign-In gagal');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Get user profile
  Future<UserData> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.me);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return UserData.fromJson(data);
      } else {
        throw Exception('Gagal memuat profil');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Update avatar
  Future<String> updateAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await _dioClient.dio.post(
        ApiEndpoints.updateAvatar,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['avatar'] ?? data['url'] ?? '';
      } else {
        throw Exception('Gagal upload avatar');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Handle Dio errors
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout, coba lagi';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request dibatalkan';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet';
      default:
        return 'Terjadi kesalahan jaringan';
    }
  }
}
