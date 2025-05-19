import 'package:json_annotation/json_annotation.dart';

part 'ttlock_init_response.g.dart';

@JsonSerializable()
class TTLockInitResponse {
  final int lockId;
  final int keyId;

  TTLockInitResponse({
    required this.lockId,
    required this.keyId,
  });

  factory TTLockInitResponse.fromJson(Map<String, dynamic> json) => _$TTLockInitResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TTLockInitResponseToJson(this);
}
