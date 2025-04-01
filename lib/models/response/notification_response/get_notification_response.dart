import 'package:flutter_getx_boilerplate/models/model/notification_model.dart';
import 'package:flutter_getx_boilerplate/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_notification_response.g.dart';

@JsonSerializable()
class NotificationResponse extends BaseResponse<List<NotificationModel>> {
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalCount;
  NotificationResponse(
      this.pageNumber, this.pageSize, this.totalPages, this.totalCount, {
    required super.data,
    super.messages,
    required super.succeeded,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}
