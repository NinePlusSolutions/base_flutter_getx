import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/models/model/leave_model.dart';
import 'package:flutter_getx_boilerplate/models/models.dart';
import 'package:flutter_getx_boilerplate/models/response/annual_leave_response/annual_leave_response.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/models/response/leave_response/common_leave_type_response.dart';
import 'package:flutter_getx_boilerplate/models/response/leave_response/get_leave_response.dart';
import 'package:flutter_getx_boilerplate/repositories/base_repository.dart';
import 'package:get/get.dart';

class LeaveRepository extends BaseRepository {
  final ApiServices apiClient;

  LeaveRepository({required this.apiClient});

  Future<LeaveTypeResponse> getCommonLeaveType() async {
    try {
      final res = await apiClient.get(ApiEndpoints.commonLeaveType);
      return LeaveTypeResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<AnnualLeaveResponse> getAnnualLeave() async {
    try {
      final res = await apiClient.get(ApiEndpoints.annualLeave);
      return AnnualLeaveResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<GetLeaveResponse> getListLeaves() async {
    try {
      final res = await apiClient.get(ApiEndpoints.leavesList);
      return GetLeaveResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<BaseResponse> submitLeave(LeaveModel leaveModel) async {
    try {
      final res = await apiClient.post(ApiEndpoints.leavesList, data: leaveModel.toJson());
      return BaseResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }
}
