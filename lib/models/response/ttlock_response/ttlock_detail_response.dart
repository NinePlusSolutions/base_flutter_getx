import 'package:json_annotation/json_annotation.dart';

part 'ttlock_detail_response.g.dart';

@JsonSerializable()
class TTLockDetailResponse {
   final int lockId;
  final String lockName;
  final String lockAlias;
  final String lockMac;
  final String? noKeyPwd;
  final int electricQuantity;
  final String featureValue;
  final int? hasGateway;
  final String? lockData;
  final int? timezoneRawOffset;
  final String? modelNum;
  final String? hardwareRevision;
  final String? firmwareRevision;
  final int? autoLockTime;
  final int? lockSound;
  final int? privacyLock;
  final int? tamperAlert;
  final int? resetButton;
  final int? openDirection;
  final int? passageMode;
  final int? passageModeAutoUnlock;
  final int date;

  TTLockDetailResponse({
   required this.lockId,
    required this.lockName,
    required this.lockAlias,
    required this.lockMac,
    this.noKeyPwd,
    required this.electricQuantity,
    required this.featureValue,
    this.hasGateway,
    this.lockData,
    this.timezoneRawOffset,
    this.modelNum,
    this.hardwareRevision,
    this.firmwareRevision,
    this.autoLockTime,
    this.lockSound,
    this.privacyLock,
    this.tamperAlert,
    this.resetButton,
    this.openDirection,
    this.passageMode,
    this.passageModeAutoUnlock,
    required this.date,
  });

  factory TTLockDetailResponse.fromJson(Map<String, dynamic> json) => _$TTLockDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TTLockDetailResponseToJson(this);
}
