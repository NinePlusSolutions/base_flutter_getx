import 'package:json_annotation/json_annotation.dart';

part 'rename_lock_request.g.dart';

@JsonSerializable()
class RenameLockRequest {
  final String? clientId;
  final String? accessToken;
  final int? lockId;
  final String? lockAlias;
  final int? date;

  RenameLockRequest({
    this.clientId,
    this.accessToken,
    this.lockId,
    this.lockAlias,
    this.date,
  });

  factory RenameLockRequest.fromJson(Map<String, dynamic> json) => _$RenameLockRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RenameLockRequestToJson(this);
}
