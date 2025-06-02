import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/lock_detail/lock_detail_controller.dart';
import 'package:get/get.dart';

class LockDialogs {
  static void showDeleteConfirmation(
    BuildContext context,
    LockDetailController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lock?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will delete the lock from your account and remove all associated data including:',
            ),
            const SizedBox(height: 8),
            const Text('• All eKeys'),
            const Text('• All passcodes'),
            const Text('• All cards and fingerprints'),
            const Text('• All unlocking records'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WARNING: This action cannot be undone.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(context);
              controller.deleteLock();
            },
          ),
        ],
      ),
    );
  }

  static void showRenameDialog(BuildContext context, LockDetailController controller) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = controller.lockInfo?.lockAlias ?? controller.lockInfo?.lockName ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Rename Lock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a new name for your lock. This name will be displayed in the app.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Lock Name',
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Get.back(),
          ),
          Obx(
            () => TextButton(
              onPressed: controller.isRenamingLock.value
                  ? null
                  : () {
                      Get.back();
                      controller.renameLock(nameController.text);
                    },
              child: controller.isRenamingLock.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('RENAME'),
            ),
          ),
        ],
      ),
    );
  }

  static void showAdminPasscodeDialog(BuildContext context, LockDetailController controller) {
    final TextEditingController passcodeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Change Admin Passcode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The admin passcode can be used to unlock the door from the keypad. '
              'It cannot be deleted and is only available to administrators.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passcodeController,
              keyboardType: TextInputType.number,
              maxLength: 9,
              decoration: const InputDecoration(
                labelText: 'New Admin Passcode',
                hintText: 'Enter 4-9 digits',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Get.back(),
          ),
          Obx(() => TextButton(
                onPressed: controller.isAdminPasscodeUpdateInProgress.value
                    ? null
                    : () {
                        Get.back();
                        controller.updateAdminPasscode(passcodeController.text.trim());
                      },
                child: controller.isAdminPasscodeUpdateInProgress.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('UPDATE'),
              )),
        ],
      ),
    );
  }

  // Thêm các dialog khác như autolock, passage mode...
}
