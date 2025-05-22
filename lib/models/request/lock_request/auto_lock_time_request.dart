import 'package:json_annotation/json_annotation.dart';

part 'auto_lock_time_request.g.dart';

@JsonSerializable()
class AutoLockTimeRequest {
  final String? clientId;
  final String? accessToken;
  final int? lockId;
  final int? seconds;
  final int? type;
  final int? date;

  AutoLockTimeRequest({
    this.clientId,
    this.accessToken,
    this.lockId,
    this.date,
    this.seconds,
    this.type,
  });

  factory AutoLockTimeRequest.fromJson(Map<String, dynamic> json) => _$AutoLockTimeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AutoLockTimeRequestToJson(this);
}
