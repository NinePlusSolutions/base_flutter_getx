// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_getx_boilerplate/models/model/user_login_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_getx_boilerplate/models/response/base_response.dart';

part 'login_response.g.dart';

@JsonSerializable(createToJson: false)
class LoginResponse extends BaseResponse<UserLoginModel> {
  LoginResponse({
    super.data,
    super.messages,
    required super.succeeded,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
