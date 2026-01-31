/// Login request model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Login response model
class LoginResponse {
  final String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
    );
  }
}

/// Register request model
class RegisterRequest {
  final String email;
  final String fullname;
  final String password;
  final String username;

  RegisterRequest({
    required this.email,
    required this.fullname,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullname': fullname,
        'password': password,
        'username': username,
      };
}

/// API error response model
class ApiErrorResponse {
  final Map<String, dynamic> errors;

  ApiErrorResponse({required this.errors});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(errors: json);
  }

  String get message {
    // Try to extract a meaningful error message
    if (errors.containsKey('message')) {
      return errors['message'] as String;
    }
    if (errors.containsKey('error')) {
      return errors['error'] as String;
    }
    // Return first error value
    return errors.values.first.toString();
  }
}

/// Google Sign-In request model
class GoogleAuthRequest {
  final String idToken;

  GoogleAuthRequest({required this.idToken});

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
      };
}

/// Google Sign-In response model
class GoogleAuthResponse {
  final String token;
  final UserData user;

  GoogleAuthResponse({
    required this.token,
    required this.user,
  });

  factory GoogleAuthResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns: { status, data: { token, user }, metadata }
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw FormatException('Missing data. Keys: ${json.keys.toList()}');
    }
    if (data['token'] == null) {
      throw FormatException(
          'Missing token in data. Keys: ${data.keys.toList()}');
    }
    if (data['user'] == null) {
      throw FormatException(
          'Missing user in data. Keys: ${data.keys.toList()}');
    }
    return GoogleAuthResponse(
      token: data['token'] as String,
      user: UserData.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}

/// User data model
class UserData {
  final String email;
  final String fullname;
  final bool isNewUser;

  UserData({
    required this.email,
    required this.fullname,
    this.isNewUser = false,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      email: json['email'] as String? ?? '',
      fullname: json['fullname'] as String? ?? json['name'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }
}
