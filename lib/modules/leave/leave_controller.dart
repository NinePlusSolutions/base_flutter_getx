import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/models/model/annual_leave_model.dart';
import 'package:flutter_getx_boilerplate/models/model/leave_model.dart';
import 'package:flutter_getx_boilerplate/models/model/leave_type_common.dart';
import 'package:flutter_getx_boilerplate/models/model/user_model.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/leave_repository.dart';
import 'package:flutter_getx_boilerplate/shared/services/user_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveController extends BaseController<LeaveRepository> {
  LeaveController(super.repository);

  // Add reactive user variable
  final user = Rx<UserModel?>(null);

  final annualLeave = Rx<AnnualLeaveData?>(null);

  final RxList<LeaveTypeModel> commonLeaveType = <LeaveTypeModel>[].obs;

  final RxList<LeaveModel> listLeaveCurrent = <LeaveModel>[].obs;

  RxBool isLoadingList = false.obs;

  @override
  onInit() {
    user.value = UserService.to.user;
    super.onInit();
  }

  @override
  Future<void> getData() async {
    await getCommonLeaveType();
    await getAnnualLeave();
    await getListLeave();
  }

  Future<void> getAnnualLeave() async {
    try {
      final res = await repository.getAnnualLeave();
      if (res.succeeded) {
        annualLeave.value = res.data;
      }
    } catch (e) {
      showError(AppLanguageKey.common_error, e.toString());
    }
  }

  Future<void> getCommonLeaveType() async {
    try {
      final res = await repository.getCommonLeaveType();
      if (res.succeeded) {
        commonLeaveType(res.data);
      }
    } catch (e) {
      showError(AppLanguageKey.common_error, e.toString());
    }
  }

  Future<void> getListLeave() async {
    isLoadingList(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      listLeaveCurrent.value = listLeaveCurrent([
        LeaveModel(
          reason: "Lí do cá nhân",
          leaveTypeId: 14,
          // Annual Leave
          fromTime: DateTime(2025, 3, 25, 8, 0),
          toTime: DateTime(2025, 3, 25, 17, 0),
          totalDay: 1,
          totalHour: 8,
          status: 5,
          totalTime: 8,
        ),
        LeaveModel(
          reason: "Đi công tác",
          leaveTypeId: 10,
          // Business travel
          fromTime: DateTime(2025, 3, 28, 9, 0),
          toTime: DateTime(2025, 3, 30, 18, 0),
          totalDay: 3,
          totalHour: 27,
          status: 3,
          totalTime: 27,
        ),
      ]);
      // final res = await repository.getListLeaves();
      // if (res.succeeded) {
      //   ;
      // }
    } catch (e) {
      showError(AppLanguageKey.common_error, e.toString());
    } finally {
      isLoadingList(false);
    }
  }

  String getLeaveTypeName(int? leaveTypeId) {
    if (leaveTypeId == null) return "Unknown Leave";
    print("commonLeaveType: $commonLeaveType");

    LeaveTypeModel leaveType =
        commonLeaveType.firstWhere((leave) => leave.id == leaveTypeId);

    Locale locale = Get.locale ?? const Locale('vi');

    if (locale.languageCode == 'en') {
      return leaveType.nameEn;
    } else if (locale.languageCode == 'ja') {
      return leaveType.nameJa;
    } else {
      return leaveType.nameVi;
    }
  }

  void showAddLeaveDialog(BuildContext context) {
    final leaveTypeController = Rx<LeaveTypeModel?>(null);
    final startDateController = Rx<DateTime?>(null);
    final endDateController = Rx<DateTime?>(null);
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Thêm Ngày Phép"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown for Leave Type
              Obx(() {
                return DropdownButtonFormField<LeaveTypeModel>(
                  value: leaveTypeController.value,
                  items: commonLeaveType
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.nameVi ?? "Unknown"),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => leaveTypeController.value = value,
                  decoration: const InputDecoration(
                    labelText: "Loại Đơn*",
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Start Date Picker
              Obx(() {
                return TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Ngày Bắt Đầu",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        startDateController.value = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      }
                    }
                  },
                  controller: TextEditingController(
                    text: startDateController.value != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(startDateController.value!)
                        : "",
                  ),
                );
              }),
              const SizedBox(height: 16),
              // End Date Picker
              Obx(() {
                return TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Ngày Kết Thúc",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        endDateController.value = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      }
                    }
                  },
                  controller: TextEditingController(
                    text: endDateController.value != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(endDateController.value!)
                        : "",
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Reason Text Field
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Lý Do*",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              if (leaveTypeController.value == null ||
                  startDateController.value == null ||
                  endDateController.value == null ||
                  reasonController.text.isEmpty) {
                Get.snackbar("Lỗi", "Vui lòng điền đầy đủ thông tin.");
                return;
              }

              final leaveModel = LeaveModel(
                leaveTypeId: leaveTypeController.value!.id,
                fromTime: startDateController.value,
                toTime: endDateController.value,
                reason: reasonController.text,
              );
              Get.back();
              _submitLeave(leaveModel);

            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  Future<void> _submitLeave(LeaveModel leaveModel) async {
    try {
      final res = await repository.submitLeave(leaveModel);
      if (res.succeeded) {
        showSuccess(AppLanguageKey.edit_success, "Yêu cầu nghỉ phép thành công");
      }

    } catch (e) {
      showError(AppLanguageKey.edit_failed, e.toString());
    }
    }
}
