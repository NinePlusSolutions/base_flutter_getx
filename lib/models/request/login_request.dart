class LoginRequest {
  final String username;
  final String password;
  final String? deviceToken;

  LoginRequest({
    required this.username,
    required this.password,
    this.deviceToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'employeeNo': username,
      'password': password,
      "deviceToken": deviceToken,
    };
  }
}
