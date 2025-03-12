import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/constants/colors.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  static showSnackbar(
    String title,
    String message, {
    int? duration,
    Color? backgroundColor,
  }) {
    Get.snackbar(
      title,
      message,
      duration: Duration(seconds: duration ?? 3),
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      borderRadius: 4,
      margin: const EdgeInsets.all(8),
    );
  }

  static Future snackBarWithAction({
    Function? onAction,
    String? title,
    String? message,
    String? actionText,
  }) async {
    final Completer completer = Completer<SnackbarStatus?>();
    bool result = false;
    Get.snackbar(
      title ?? "Snackbar Title",
      message ?? "Snackbar Message",
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.white,
      backgroundColor: ColorConstants.highlightPrimary.withOpacity(.7),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          completer.complete(status);
        }
      },
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          if (onAction != null) {
            onAction(result);
          }
        },
        child: Text(
          actionText ?? 'Dismiss',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return completer.future;
  }
}
