import 'package:flutter_getx_boilerplate/models/model/leave_model.dart';
import 'package:flutter_getx_boilerplate/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_leave_response.g.dart';

@JsonSerializable()
class GetLeaveResponse extends BaseResponse<List<LeaveModel>> {
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalCount;
  GetLeaveResponse(
      this.pageNumber, this.pageSize, this.totalPages, this.totalCount, {
        required super.data,
        super.messages,
        required super.succeeded,
      });

  factory GetLeaveResponse.fromJson(Map<String, dynamic> json) =>
      _$GetLeaveResponseFromJson(json);
}
