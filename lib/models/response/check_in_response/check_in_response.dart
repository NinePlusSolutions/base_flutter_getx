// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_getx_boilerplate/models/response/base_response.dart';

part 'check_in_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class CheckInResponse<T> extends BaseResponse<T> {
  CheckInResponse({
    super.data,
    super.messages,
    required super.succeeded,
  });

  factory CheckInResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse.fromJson(
      json,
      fromJsonT,
    ) as CheckInResponse<T>;
  }
}
