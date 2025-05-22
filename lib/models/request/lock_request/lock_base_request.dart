import 'package:json_annotation/json_annotation.dart';

part 'lock_base_request.g.dart';

@JsonSerializable()
class LockBaseRequest {
  final String? clientId;
  final String? accessToken;
  final int? lockId;
  final int? date;

  LockBaseRequest({
    this.clientId,
    this.accessToken,
    this.lockId,
    this.date,
  });

  factory LockBaseRequest.fromJson(Map<String, dynamic> json) => _$LockBaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LockBaseRequestToJson(this);
}
