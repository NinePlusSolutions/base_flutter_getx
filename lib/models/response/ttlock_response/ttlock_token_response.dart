class TTLockTokenResponse {
  final String accessToken;
  final int uid;
  final int expiresIn;
  final String refreshToken;
  final DateTime createdAt;

  TTLockTokenResponse({
    required this.accessToken,
    required this.uid,
    required this.expiresIn,
    required this.refreshToken,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TTLockTokenResponse.fromJson(Map<String, dynamic> json) {
    return TTLockTokenResponse(
      accessToken: json['access_token'] ?? '',
      uid: json['uid'] ?? 0,
      expiresIn: json['expires_in'] ?? 0,
      refreshToken: json['refresh_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'uid': uid,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  bool get isExpired {
    final expirationDate = createdAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expirationDate);
  }
}
