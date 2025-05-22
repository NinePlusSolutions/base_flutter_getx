class LoginRequest {
  final String username;
  final String password;
  final int? expiresInMins;

  LoginRequest({
    required this.username,
    required this.password,
    this.expiresInMins,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      "expiresInMins": expiresInMins,
    };
  }
}
