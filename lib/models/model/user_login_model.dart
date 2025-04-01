import 'package:json_annotation/json_annotation.dart';

part 'user_login_model.g.dart';

@JsonSerializable()
class UserLoginModel {
  final String? token;
  final String? refreshToken;
  final String? avatarUrl;
  final String? role;
  final String? refreshTokenExpiryTime;

  UserLoginModel({
    this.token,
    this.refreshToken,
    this.avatarUrl,
    this.role,
    this.refreshTokenExpiryTime,
  });

  factory UserLoginModel.fromJson(Map<String, dynamic> json) =>
      _$UserLoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginModelToJson(this);
}
