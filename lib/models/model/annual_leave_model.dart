import 'package:json_annotation/json_annotation.dart';

part 'annual_leave_model.g.dart';

@JsonSerializable()
class AnnualLeaveData {
  final List<dynamic>? employeeLeaveResponses;
  final double? totalLeaveCanUse;
  final double? leaveUsed;
  final int? unpaidLeave;
  final double? remainingLeave;

  AnnualLeaveData({
    this.employeeLeaveResponses,
    this.totalLeaveCanUse,
    this.leaveUsed,
    this.unpaidLeave,
    this.remainingLeave,
  });

  factory AnnualLeaveData.fromJson(Map<String, dynamic> json) =>
      _$AnnualLeaveDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnnualLeaveDataToJson(this);
}
