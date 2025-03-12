import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_getx_boilerplate/shared/constants/colors.dart';
import 'package:flutter_getx_boilerplate/shared/utils/utils.dart';
import 'package:get/get.dart';

class DeBouncer {
  int? milliseconds; // The delay time for debouncing in milliseconds
  VoidCallback? action; // The action to be executed

  static Timer? timer; // A static Timer instance to manage the debouncing

  static run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel(); // Cancel any previous Timer instance
    }
    timer = Timer(
      Duration(milliseconds: const Duration(milliseconds: 500).inMilliseconds),
      action, // Schedule the action after a delay
    );
  }
}

abstract class BaseController<T> extends GetxController {
  final T repository;
  BaseController(this.repository);

  final isInitialized = false.obs;

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  _initData() async {
    await getData();
    isInitialized.value = true;
  }

  Future getData() async {}

  showError(
    String title,
    String message, {
    int duration = 3,
  }) {
    DeBouncer.run(() {
      SnackbarHelper.showSnackbar(
        title,
        message,
        duration: duration,
        backgroundColor: ColorConstants.supportErrorPrimary,
      );
    });
  }

  showSuccess(
    String title,
    String message, {
    int duration = 3,
  }) {
    DeBouncer.run(() {
      DeBouncer.run(() {
        SnackbarHelper.showSnackbar(
          title,
          message,
          duration: duration,
          backgroundColor: ColorConstants.supportSuccessPrimary,
        );
      });
    });
  }

  setLoading(bool value) {
    if (value) {
      EasyLoading.show();
    } else {
      EasyLoading.dismiss();
    }
  }
}
