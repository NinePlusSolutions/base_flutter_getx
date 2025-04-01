import 'package:flutter_getx_boilerplate/models/model/annual_leave_model.dart';
import 'package:flutter_getx_boilerplate/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'annual_leave_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class AnnualLeaveResponse extends BaseResponse<AnnualLeaveData> {
  AnnualLeaveResponse({
    super.data,
    super.messages,
    required super.succeeded,
  });

  factory AnnualLeaveResponse.fromJson(Map<String, dynamic> json) =>
      _$AnnualLeaveResponseFromJson(json);
}
