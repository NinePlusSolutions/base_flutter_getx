import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int? id;
  final String? employeeNo;
  final String? fullName;
  final DateTime? birthday;
  final int? gender;
  final String? phoneNo;
  final String? email;
  final String? address;
  final String? placeOfBirth;
  final DateTime? workingDateFrom;
  final DateTime? workingDateTo;
  final DateTime? contractFrom;
  final DateTime? contractTo;
  final String? educationLevel;
  final String? softSkill;
  final String? businessExp;
  final double? salary;
  final int? maritalStatus;
  final int? numberChild;
  final String? nickName;
  final String? chatId;
  final String? imageURL;
  final String? katakanaName;
  final String? taxCode;
  final String? socialInsuranceNumber;
  final int? numberOfDependents;
  final String? familyPhoneNo;
  final String? contractNumber;
  final String? contractUrl;
  final int? countProject;
  final PositionResponse? positionResponse;
  final TeamResponse? teamResponse;
  final EmployeeStatusResponse? employeeStatusResponse;
  final ContractTypeResponse? contractTypeResponse;

  UserModel({
    this.id,
    this.employeeNo,
    this.fullName,
    this.birthday,
    this.gender,
    this.phoneNo,
    this.email,
    this.address,
    this.placeOfBirth,
    this.workingDateFrom,
    this.workingDateTo,
    this.contractFrom,
    this.contractTo,
    this.educationLevel,
    this.softSkill,
    this.businessExp,
    this.salary,
    this.maritalStatus,
    this.numberChild,
    this.nickName,
    this.chatId,
    this.imageURL,
    this.katakanaName,
    this.taxCode,
    this.socialInsuranceNumber,
    this.numberOfDependents,
    this.familyPhoneNo,
    this.contractNumber,
    this.contractUrl,
    this.countProject,
    this.positionResponse,
    this.teamResponse,
    this.employeeStatusResponse,
    this.contractTypeResponse,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? fullName,
    String? katakanaName,
    String? nickName,
    DateTime? birthday,
    int? gender,
    int? maritalStatus,
    int? numberChild,
    String? phoneNo,
    String? placeOfBirth,
    String? address,
  }) {
    return UserModel(
      id: id,
      employeeNo: employeeNo,
      fullName: fullName ?? this.fullName,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email,
      address: address ?? this.address,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      workingDateFrom: workingDateFrom,
      workingDateTo: workingDateTo,
      contractFrom: contractFrom,
      contractTo: contractTo,
      educationLevel: educationLevel,
      softSkill: softSkill,
      businessExp: businessExp,
      salary: salary,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      numberChild: numberChild ?? this.numberChild,
      nickName: nickName ?? this.nickName,
      chatId: chatId,
      imageURL: imageURL,
      katakanaName: katakanaName ?? this.katakanaName,
      taxCode: taxCode,
      socialInsuranceNumber: socialInsuranceNumber,
      numberOfDependents: numberOfDependents,
      familyPhoneNo: familyPhoneNo,
      contractNumber: contractNumber,
      contractUrl: contractUrl,
      countProject: countProject,
      positionResponse: positionResponse,
      teamResponse: teamResponse,
      employeeStatusResponse: employeeStatusResponse,
      contractTypeResponse: contractTypeResponse,
    );
  }
}

@JsonSerializable()
class PositionResponse {
  final int? id;
  final String? nameEn;
  final String? nameVi;
  final String? nameJa;

  PositionResponse({
    this.id,
    this.nameEn,
    this.nameVi,
    this.nameJa,
  });

  factory PositionResponse.fromJson(Map<String, dynamic> json) =>
      _$PositionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PositionResponseToJson(this);
}

@JsonSerializable()
class TeamResponse {
  final int? id;
  final String? nameEn;
  final String? nameVi;
  final String? nameJa;

  TeamResponse({
    this.id,
    this.nameEn,
    this.nameVi,
    this.nameJa,
  });

  factory TeamResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TeamResponseToJson(this);
}

@JsonSerializable()
class EmployeeStatusResponse {
  final int? id;
  final String? nameEn;
  final String? nameVi;
  final String? nameJa;
  final String? color;

  EmployeeStatusResponse({
    this.id,
    this.nameEn,
    this.nameVi,
    this.nameJa,
    this.color,
  });

  factory EmployeeStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$EmployeeStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeStatusResponseToJson(this);
}

@JsonSerializable()
class ContractTypeResponse {
  final int? id;
  final String? nameEn;
  final String? nameVi;
  final String? nameJa;

  ContractTypeResponse({
    this.id,
    this.nameEn,
    this.nameVi,
    this.nameJa,
  });

  factory ContractTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$ContractTypeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ContractTypeResponseToJson(this);
}
