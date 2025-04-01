import 'package:json_annotation/json_annotation.dart';

part 'leave_type_common.g.dart';

@JsonSerializable()
class LeaveTypeModel {
  final int id;
  final String nameEn;
  final String nameVi;
  final String nameJa;
  final String? color;
  final String? description;
  final int typeFlag;
  final String acronym;

  LeaveTypeModel({
    required this.id,
    required this.nameEn,
    required this.nameVi,
    required this.nameJa,
    this.color,
    this.description,
    required this.typeFlag,
    required this.acronym,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) => _$LeaveTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveTypeModelToJson(this);
}
