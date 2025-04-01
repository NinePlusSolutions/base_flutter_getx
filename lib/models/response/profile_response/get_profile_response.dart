import 'package:flutter_getx_boilerplate/models/model/user_model.dart';
import 'package:flutter_getx_boilerplate/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_profile_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class GetProfileResponse extends BaseResponse<ProfileData> {
  GetProfileResponse({
    super.data,
    super.messages,
    required super.succeeded,
  });

  factory GetProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$GetProfileResponseFromJson(json);
}

@JsonSerializable()
class ProfileData {
  final UserModel? employee;
  final dynamic employeeSalary;
  final dynamic employeeEmergencyContact;
  final List<dynamic>? employeeForeignLanguage;
  final List<dynamic>? employeeProgrammingLanguage;
  final dynamic employeeIdentity;

  ProfileData({
    this.employee,
    this.employeeSalary,
    this.employeeEmergencyContact,
    this.employeeForeignLanguage,
    this.employeeProgrammingLanguage,
    this.employeeIdentity,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}
