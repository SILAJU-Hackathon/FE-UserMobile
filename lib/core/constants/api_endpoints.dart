/// API endpoints for SILAJU backend
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'https://xryz-test-silaju.hf.space';

  // Auth endpoints
  static const String login = '/api/auth/user/login';
  static const String register = '/api/auth/user/register';
  static const String googleAuth = '/api/auth/google';
  static const String me = '/api/auth/me';
  static const String updateAvatar = '/api/users/avatar';

  // Report endpoints (for future use)
  static const String createReport = '/api/reports';
  static const String getReports = '/api/reports';
  static const String getReportById = '/api/reports/{id}';
}
