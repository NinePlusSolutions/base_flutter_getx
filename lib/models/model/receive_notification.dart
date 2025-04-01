
import 'package:json_annotation/json_annotation.dart';

part 'receive_notification.g.dart';
@JsonSerializable()
class ReceiveNotification {
  final String? navigate;
  final String? notificationId;

  ReceiveNotification(this.navigate, this.notificationId);

  factory ReceiveNotification.fromJson(Map<String, dynamic> json) =>
      _$ReceiveNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiveNotificationToJson(this);
}