import 'package:flutter_getx_boilerplate/models/model/leave_type_common.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common_leave_type_response.g.dart';

@JsonSerializable()
class LeaveTypeResponse {
  final List<LeaveTypeModel> data;
  final List<String> messages;
  final bool succeeded;

  LeaveTypeResponse({
    required this.data,
    required this.messages,
    required this.succeeded,
  });

  factory LeaveTypeResponse.fromJson(Map<String, dynamic> json) => _$LeaveTypeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveTypeResponseToJson(this);
}
