import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/lock_detail/lock_detail_controller.dart';
import 'package:get/get.dart';

class LockActionControls extends GetView<LockDetailController> {
  final String controlType;

  const LockActionControls({
    super.key,
    required this.controlType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final bool isActionInProgress = controlType == 'remote'
              ? controller.isRemoteActionInProgress.value
              : controller.isBluetoothActionInProgress.value;

          final String currentAction = controlType == 'remote' ? controller.remoteAction.value : '';

          return Row(
            children: [
              // Unlock Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  onPressed: _getUnlockButtonState(isActionInProgress, currentAction) ? null : _handleUnlock,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('UNLOCK'),
                ),
              ),
              const SizedBox(width: 16),
              // Lock Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  onPressed: _getLockButtonState(isActionInProgress, currentAction) ? null : _handleLock,
                  icon: const Icon(Icons.lock),
                  label: const Text('LOCK'),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  bool _getUnlockButtonState(bool isActionInProgress, String currentAction) {
    if (controlType == 'remote') {
      return isActionInProgress;
    } else {
      // Bluetooth
      return controller.lockData == null || isActionInProgress;
    }
  }

  bool _getLockButtonState(bool isActionInProgress, String currentAction) {
    if (controlType == 'remote') {
      return isActionInProgress;
    } else {
      // Bluetooth
      return controller.lockData == null || isActionInProgress;
    }
  }

  void _handleUnlock() {
    if (controlType == 'remote') {
      controller.remoteUnlock();
    } else {
      // Bluetooth
      if (controller.lockData != null) {
        controller.unlockByBluetooth(controller.lockData!);
      }
    }
  }

  void _handleLock() {
    if (controlType == 'remote') {
      controller.remoteLock();
    } else {
      // Bluetooth
      if (controller.lockData != null) {
        controller.lockByBluetooth(controller.lockData!);
      }
    }
  }
}
