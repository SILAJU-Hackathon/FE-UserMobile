import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silaju/features/auth/models/auth_models.dart';
import 'package:silaju/features/auth/services/auth_service.dart';
import 'package:silaju/features/auth/services/social_auth_service.dart';
import 'package:silaju/core/network/dio_client.dart';
import 'package:silaju/core/constants/api_endpoints.dart';

/// Auth state
class AuthState {
  final bool isAuthenticated;
  final String? token;
  final bool isLoading;
  final String? error;
  final UserData? user;

  AuthState({
    this.isAuthenticated = false,
    this.token,
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    bool? isLoading,
    String? error,
    UserData? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

/// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final DioClient _dioClient = DioClient();

  AuthNotifier() : super(AuthState()) {
    _loadToken();
  }

  /// Load saved token on app start
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      _dioClient.setAuthToken(token);
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
      );
      // Fetch profile in background
      fetchProfile();
    }
  }

  /// Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.token);

      // Set token in Dio client
      _dioClient.setAuthToken(response.token);

      // Fetch profile
      await fetchProfile();

      state = state.copyWith(
        isAuthenticated: true,
        token: response.token,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Register
  Future<void> register({
    required String email,
    required String fullname,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = RegisterRequest(
        email: email,
        fullname: fullname,
        password: password,
        username: username,
      );

      await _authService.register(request);

      state = state.copyWith(isLoading: false);

      // Auto login after successful registration
      await login(email, password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    print('DEBUG: Starting signInWithGoogle flow...');

    try {
      // Step 1: Google Sign-In
      print('DEBUG: Calling _googleAuthService.signInWithGoogle()...');
      final googleAccount = await _googleAuthService.signInWithGoogle();
      if (googleAccount == null) {
        print('DEBUG: Google Sign-In canceled by user.');
        throw Exception('Google Sign-In dibatalkan');
      }
      print('DEBUG: Google Account obtained: ${googleAccount.email}');

      // Step 2: Get ID token
      print('DEBUG: Getting ID token...');
      final idToken = await _googleAuthService.getIdToken();
      if (idToken == null) {
        print('DEBUG: ID Token is null.');
        throw Exception('Gagal mendapatkan token Google');
      }
      print('DEBUG: ID Token obtained (length: ${idToken.length})');

      // Step 3: Send to backend
      print('DEBUG: Sending token to backend: ${ApiEndpoints.googleAuth}');
      final response = await _authService.signInWithGoogle(idToken);
      print('DEBUG: Backend response received. Token: ${response.token}');

      // Step 4: Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.token);
      print('DEBUG: Token saved to SharedPreferences.');

      // Set token in Dio client
      _dioClient.setAuthToken(response.token);

      state = state.copyWith(
        isAuthenticated: true,
        token: response.token,
        isLoading: false,
        user: response.user,
      );
      print('DEBUG: AuthNotifier state updated. Success!');
    } catch (e) {
      print('DEBUG: Error caught in signInWithGoogle: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Fetch user profile
  Future<void> fetchProfile() async {
    try {
      final user = await _authService.getProfile();
      state = state.copyWith(user: user);
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  /// Upload avatar
  Future<void> uploadAvatar(String filePath) async {
    try {
      final newAvatarUrl = await _authService.updateAvatar(filePath);
      if (state.user != null) {
        state = state.copyWith(
          user: state.user!.copyWith(avatar: newAvatarUrl),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _dioClient.clearAuthToken();
    await _googleAuthService.signOut();

    state = AuthState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
