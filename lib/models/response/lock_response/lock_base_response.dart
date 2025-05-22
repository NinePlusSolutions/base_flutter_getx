import 'package:json_annotation/json_annotation.dart';

part 'lock_base_response.g.dart';

@JsonSerializable()
class LockBaseResponse {
  final int errcode;
  final String errmsg;

  LockBaseResponse({
    required this.errcode,
    required this.errmsg,
  });

  factory LockBaseResponse.fromJson(Map<String, dynamic> json) => _$LockBaseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LockBaseResponseToJson(this);

  bool get isSuccess => errcode == 0;
}
