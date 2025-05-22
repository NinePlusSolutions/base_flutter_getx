import 'package:json_annotation/json_annotation.dart';

part 'ekey_detail_response.g.dart';

@JsonSerializable()
class EkeyDetailResponse {
  final int? keyId;
  final String? lockData;
  final int? lockId;
  final String? userType;
  final String? keyStatus;
  final String? lockName;
  final String? lockAlias;
  final String? lockMac;
  final String? noKeyPwd;
  final int? electricQuantity;
  final int? startDate;
  final int? endDate;
  final String? remarks;
  final int? keyRight;
  final String? featureValue;
  final int? remoteEnable;
  final int? passageMode;
  final int? groupId;
  final String? groupName;

  EkeyDetailResponse({
    this.keyId,
    this.lockData,
    this.lockId,
    this.userType,
    this.keyStatus,
    this.lockName,
    this.lockAlias,
    this.lockMac,
    this.noKeyPwd,
    this.electricQuantity,
    this.startDate,
    this.endDate,
    this.remarks,
    this.keyRight,
    this.featureValue,
    this.remoteEnable,
    this.passageMode,
    this.groupId,
    this.groupName,
  });

  factory EkeyDetailResponse.fromJson(Map<String, dynamic> json) => _$EkeyDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EkeyDetailResponseToJson(this);
}
