import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/lock_detail/lock_detail_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';

class LockDetailScreen extends GetView<LockDetailController> {
  const LockDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: _buildAppbar(context),
        body: _buildBody(context),
      ),
    );
  }

  _buildAppbar(BuildContext context) {
    return AppBarWidget(
      backgroundColor: context.colors.primary,
      title: controller.lockInfo.value['lockAlias'] ?? controller.lockInfo.value['lockName'],
      elevation: 2,
      actions: [
        _buildAction(context),
      ],
    );
  }

  _buildAction(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => _showSettingsBottomSheet(context),
      tooltip: 'Disconnect',
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(context),
            _buildLockControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final lockInfo = controller.lockInfo.value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    lockInfo['lockAlias'] ?? lockInfo['lockName'] ?? 'Smart Lock',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (controller.batteryLevel.value > 0) ...[
                  Column(
                    children: [
                      Obx(() => Icon(
                            _getBatteryIcon(controller.batteryLevel.value),
                            color: _getBatteryColor(controller.batteryLevel.value),
                            size: 24,
                          )),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            '${controller.batteryLevel.value}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getBatteryColor(controller.batteryLevel.value),
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                ],
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MAC Address:', style: TextStyle(fontSize: 14)),
                Text(
                  lockInfo['lockMac'] ?? 'N/A',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockControls(BuildContext context) {
    final bool isInitialized = controller.isLockInitialized;

    if (controller.isInitializing.value) {
      return Container(
        margin: const EdgeInsets.only(top: 32),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Initializing lock..."),
            ],
          ),
        ),
      );
    }

    if (!isInitialized) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            margin: const EdgeInsets.only(bottom: 24),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => controller.initLock(),
              icon: const Icon(Icons.add_circle_outline, size: 32, color: Colors.white),
              label: const Text(
                'INITIALIZE LOCK',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const Text(
            'This lock needs to be initialized with your account before use',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return _buildRemoteControls(context);
  }

  Widget _buildRemoteControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Obx(() {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isRemoteActionInProgress.value ? null : () => controller.remoteUnlock(),
                  icon: controller.isRemoteActionInProgress.value && controller.remoteAction.value == 'unlock'
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.lock_open),
                  label: const Text('REMOTE UNLOCK'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isRemoteActionInProgress.value ? null : () => controller.remoteLock(),
                  icon: controller.isRemoteActionInProgress.value && controller.remoteAction.value == 'lock'
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.lock),
                  label: const Text('REMOTE LOCK'),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              // Remote Unlock Setting
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
                              Navigator.pop(context);
                              controller.toggleRemoteUnlockSwitch();
                            },
                            activeColor: Colors.teal,
                          ),
                  )),

              // Future settings options - currently disabled
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined),
                title: const Text('Manage Access Codes'),
                subtitle: const Text('Create and manage passcodes'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                enabled: false,
                onTap: () {
                  // Future implementation
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.timelapse),
                title: const Text('Auto-Lock Settings'),
                subtitle: const Text('Configure automatic locking'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                enabled: false,
                onTap: () {
                  // Future implementation
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                subtitle: const Text('Configure lock event notifications'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                enabled: false,
                onTap: () {
                  // Future implementation
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Advanced options
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.red),
                title: const Text('Delete Lock', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Remove all data from lock'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteLockConfirmationDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteLockConfirmationDialog(BuildContext context) {
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

  IconData _getBatteryIcon(int level) {
    if (level >= 80) {
      return Icons.battery_full;
    } else if (level >= 60) {
      return Icons.battery_5_bar;
    } else if (level >= 30) {
      return Icons.battery_3_bar;
    } else if (level >= 15) {
      return Icons.battery_2_bar;
    } else {
      return Icons.battery_alert;
    }
  }

  Color _getBatteryColor(int level) {
    if (level >= 50) {
      return Colors.green;
    } else if (level >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
