import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/shared/constants/theme.dart';

/// A common dialog component that supports two types:
/// 1. Notification dialog with a single OK button
/// 2. Yes/No confirmation dialog with primary and cancel actions
class CommonDialog {
  /// Shows a notification dialog with a single OK button
  ///
  /// [title] - Dialog title (defaults to "Notification")
  /// [description] - Dialog message (defaults to empty string)
  /// [buttonText] - Text for the OK button (defaults to "OK")
  static Future<void> showNotification({
    String title = "Notification",
    String description = "",
    String buttonText = "OK",
    VoidCallback? onConfirm,
  }) {
    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Get.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: kDefaultPadding / 2),
                Text(
                  description,
                  style: Get.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: kDefaultPadding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.primary,
                    foregroundColor: Get.theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Get.back();
                    if (onConfirm != null) onConfirm();
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Shows a confirmation dialog with Yes and No buttons
  ///
  /// [title] - Dialog title (defaults to "Notification")
  /// [description] - Dialog message (defaults to empty string)
  /// [confirmText] - Text for the confirm button (defaults to translated "ok")
  /// [cancelText] - Text for the cancel button (defaults to translated "no")
  /// [onConfirm] - Callback when confirm button is pressed
  /// [onCancel] - Callback when cancel button is pressed
  static Future<void> showConfirmation({
    String title = "Notification",
    String description = "",
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Get.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: kDefaultPadding / 2),
                Text(
                  description,
                  style: Get.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: kDefaultPadding),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.onPrimary,
                        foregroundColor: Get.theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        Get.back();
                        if (onCancel != null) onCancel();
                      },
                      child: Text(cancelText ?? 'no'.tr),
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding / 2),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        foregroundColor: Get.theme.colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        Get.back();
                        if (onConfirm != null) onConfirm();
                      },
                      child: Text(confirmText ?? 'ok'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
