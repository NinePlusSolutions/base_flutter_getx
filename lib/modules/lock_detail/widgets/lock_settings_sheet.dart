import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/lock_detail/lock_detail_controller.dart';
import 'package:flutter_getx_boilerplate/routes/routes.dart';
import 'package:get/get.dart';

class LockSettingsSheet extends GetView<LockDetailController> {
  final VoidCallback onRenameTap;
  final VoidCallback onAdminPasscodeTap;
  final VoidCallback onPassageModeTap;
  final VoidCallback onAutoLockTap;
  final VoidCallback onDeleteTap;

  const LockSettingsSheet({
    super.key,
    required this.onRenameTap,
    required this.onAdminPasscodeTap,
    required this.onPassageModeTap,
    required this.onAutoLockTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, size: 24),
              const SizedBox(width: 16),
              const Text(
                'Lock Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Manage Passcodes'),
            subtitle: const Text('View and edit existing passcodes'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.back();
              Get.toNamed(
                Routes.passcodeManager,
                arguments: controller.lockInfo,
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Create Passcode'),
            subtitle: const Text('Generate new lock passcodes'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.back();
              Get.toNamed(
                Routes.createPasscode,
                arguments: controller.lockInfo,
              );
            },
          ),

          Obx(() => ListTile(
                leading: const Icon(Icons.router),
                title: const Text('Remote Control'),
                subtitle: const Text('Allow lock to be controlled via gateway'),
                trailing: controller.isRemoteUnlockSettingInProgress.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: controller.remoteControlState.value,
                        onChanged: (_) {
                          Get.back();
                          controller.toggleRemoteUnlockSwitch();
                        },
                        activeColor: Colors.teal,
                      ),
              )),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename Lock'),
            subtitle: const Text('Change lock display name'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.back();
              onRenameTap();
            },
          ),

          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Admin Passcode'),
            subtitle: const Text('Change super passcode'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.back();
              onAdminPasscodeTap();
            },
          ),

          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Passage Mode'),
            subtitle: const Text('Configure automatic unlocking periods'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.back();
              onPassageModeTap();
            },
          ),

          ListTile(
            leading: const Icon(Icons.timelapse),
            title: const Text('Auto-Lock Settings'),
            subtitle: const Text('Configure automatic locking'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.back();
              onAutoLockTap();
            },
          ),

          const SizedBox(height: 16),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.red),
            title: const Text('Delete Lock', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Remove all data from lock'),
            onTap: () {
              Get.back();
              onDeleteTap();
            },
          ),
        ],
      ),
    );
  }
}