import 'package:json_annotation/json_annotation.dart';

part 'leave_model.g.dart';

@JsonSerializable()
class LeaveModel {
  final String? reason;
  final int? leaveTypeId;
  final DateTime? fromTime;
  final DateTime? toTime;
  final int? totalDay;
  final int? totalHour;
  final int? status;
  final int? totalTime;

  LeaveModel({
    this.reason,
    this.leaveTypeId,
    this.fromTime,
    this.toTime,
    this.totalDay,
    this.totalHour,
    this.status,
    this.totalTime,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveModelToJson(this);
}
