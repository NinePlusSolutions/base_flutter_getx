import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/models/model/annual_leave_model.dart';
import 'package:flutter_getx_boilerplate/models/model/user_model.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/home_repository.dart';
import 'package:flutter_getx_boilerplate/repositories/profile_repository.dart';
import 'package:flutter_getx_boilerplate/repositories/leave_repository.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/modules/bottom_naviagte/bottom_navigate_controller.dart';
import 'package:flutter_getx_boilerplate/shared/services/user_service.dart';
import 'package:get/get.dart';

class HomeController extends BaseController<HomeRepository> {
  HomeController(super.repository);

  final searchController = TextEditingController();
  final profileRepository = Get.find<ProfileRepository>();
  final leaveRepository = Get.find<LeaveRepository>();

  // Add reactive user variable
  final user = Rx<UserModel?>(null);
  final annualLeave = Rx<AnnualLeaveData?>(null);

  @override
  void onInit() {
    super.onInit();
    // Get user data when controller initializes
    getData();
    getAnnualLeave();
  }

  @override
  Future getData() async {
    try {
      final res = await profileRepository.getProfile();
      if (res.succeeded && res.data?.employee != null) {
        // Update both UserService and local user variable
        UserService.to.user = res.data?.employee;
        user.value = res.data?.employee;
      }
    } catch (e) {
      showError("", e.toString());
    }
  }

  Future<void> getAnnualLeave() async {
    try {
      final res = await leaveRepository.getAnnualLeave();
      if (res.succeeded) {
        annualLeave.value = res.data;
      }
    } catch (e) {
      showError("", e.toString());
    }
  }

  Future<void> checkIn() async {
    try {
      final res = await repository.checkIn("CheckIn");
      if (res.succeeded) {
        showSuccess(AppLanguageKey.check_in, AppLanguageKey.check_in_success);
      } else {
        showError(AppLanguageKey.check_in, res.messages?[0].messageText ?? "");
      }
    } catch (e) {
      showError(AppLanguageKey.check_in, AppLanguageKey.check_in_failed);
    }
  }

  Future<void> checkOut() async {
    try {
      final res = await repository.checkIn("CheckOut");
      if (res.succeeded) {
        showSuccess(AppLanguageKey.check_out, AppLanguageKey.check_out);
      } else {
        showError(AppLanguageKey.check_out, res.messages?[0].messageText ?? "");
      }
    } catch (e) {
      showError(AppLanguageKey.check_out, AppLanguageKey.check_out_failed);
    }
  }

  void goToProfileDetail() {
    NavigatorHelper.toProfileDetail();
  }

  void changeNavToDashboard() {
    final bottomNavController = Get.find<BottomNavController>();
    bottomNavController.selectedIndex.value = 1;
  }

  void changeNavToLeave() {
    final bottomNavController = Get.find<BottomNavController>();
    bottomNavController.selectedIndex.value = 2;
  }
}
