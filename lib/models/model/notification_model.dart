import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  final String title;
  final String content;
  final String description;
  final String employeeNoSend;
  final String employeeImageSend;
  final DateTime dateReceiver;
  final int status;
  final String type;
  final DateTime createdOn;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.employeeNoSend,
    required this.employeeImageSend,
    required this.dateReceiver,
    required this.status,
    required this.type,
    required this.createdOn,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
