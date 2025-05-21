import 'package:json_annotation/json_annotation.dart';

part 'ttlock_base_response.g.dart';

@JsonSerializable()
class TTLockBaseResponse {
  final int errcode;
  final String errmsg;

  TTLockBaseResponse({
    required this.errcode,
    required this.errmsg,
  });

  factory TTLockBaseResponse.fromJson(Map<String, dynamic> json) => 
      _$TTLockBaseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TTLockBaseResponseToJson(this);
  
  bool get isSuccess => errcode == 0;
}