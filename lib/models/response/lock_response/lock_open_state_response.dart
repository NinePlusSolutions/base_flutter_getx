import 'package:flutter_getx_boilerplate/shared/enum/enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lock_open_state_response.g.dart';

@JsonSerializable()
class LockOpenStateResponse {
  final LockOpenState? state;

  LockOpenStateResponse({
    this.state,
  });

  factory LockOpenStateResponse.fromJson(Map<String, dynamic> json) => _$LockOpenStateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LockOpenStateResponseToJson(this);
}
