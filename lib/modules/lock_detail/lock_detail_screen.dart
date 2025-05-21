import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/lock_detail/lock_detail_controller.dart';
import 'package:flutter_getx_boilerplate/routes/routes.dart';
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
      title: controller.lockInfo?.lockAlias ?? controller.lockInfo?.lockName ?? 'Unknown',
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
    final lockInfo = controller.lockInfo;

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
                    lockInfo?.lockAlias ?? lockInfo?.lockAlias ?? 'Unknown',
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
                  lockInfo?.lockMac ?? 'N/A',
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
                  _showRenameLockDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.vpn_key),
                title: const Text('Admin Passcode'),
                subtitle: const Text('Change super passcode'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  _showAdminPasscodeDialog(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Passage Mode'),
                subtitle: const Text('Configure automatic unlocking periods'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  _showPassageModeDialog(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.timelapse),
                title: const Text('Auto-Lock Settings'),
                subtitle: const Text('Configure automatic locking'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  _showAutoLockTimeDialog(context);
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
                  Get.back();
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

  void _showRenameLockDialog(BuildContext context) {
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
              maxLength: 20, // Reasonable length limit
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          Obx(() => TextButton(
                onPressed: controller.isRenamingLock.value
                    ? null
                    : () {
                        Navigator.pop(context);
                        controller.renameLock(nameController.text);
                      },
                child: controller.isRenamingLock.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('RENAME'),
              )),
        ],
      ),
    );
  }

  void _showAdminPasscodeDialog(BuildContext context) {
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
            onPressed: () => Navigator.pop(context),
          ),
          Obx(() => TextButton(
                onPressed: controller.isAdminPasscodeUpdateInProgress.value
                    ? null
                    : () {
                        Navigator.pop(context);
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

  void _showAutoLockTimeDialog(BuildContext context) {
    int selectedSeconds = controller.autoLockTime.value ?? 0;

    // List of common time options
    final List<int> commonOptions = [0, 5, 10, 15, 30, 60, 120, 180];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Auto Lock Settings'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set how quickly your lock will automatically lock itself after being unlocked.',
                  ),
                  const SizedBox(height: 16),

                  // Radio buttons for common options
                  for (final seconds in commonOptions)
                    RadioListTile<int>(
                      dense: true,
                      title: seconds > 0
                          ? Text('$seconds ${seconds == 1 ? 'second' : 'seconds'}')
                          : const Text('Disabled'),
                      subtitle:
                          seconds > 0 ? const Text('Auto lock after unlocking') : const Text('No automatic locking'),
                      value: seconds,
                      groupValue: selectedSeconds,
                      onChanged: (value) {
                        setState(() {
                          selectedSeconds = value!;
                        });
                      },
                    ),

                  // Custom option
                  const SizedBox(height: 8),
                  const Text('Custom setting:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          min: 0,
                          max: 300, // Maximum 5 minutes
                          divisions: 30,
                          value: selectedSeconds.toDouble(),
                          label: selectedSeconds > 0 ? '$selectedSeconds seconds' : 'Disabled',
                          onChanged: (value) {
                            setState(() {
                              selectedSeconds = value.round();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          selectedSeconds > 0 ? '$selectedSeconds s' : 'Off',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context),
            ),
            Obx(() => TextButton(
                  onPressed: controller.isAutoLockUpdateInProgress.value
                      ? null
                      : () {
                          Navigator.pop(context);
                          controller.setAutoLockTime(selectedSeconds);
                        },
                  child: controller.isAutoLockUpdateInProgress.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SAVE'),
                )),
          ],
        ),
      ),
    );
  }

  void _showPassageModeDialog(BuildContext context) {
    // Load passage mode configuration first
    controller.getPassageModeConfiguration();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Passage Mode'),
        content: Obx(() {
          if (controller.isPassageModeConfigLoading.value) {
            return const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'During passage mode, the lock will remain unlocked during configured time periods.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Enable Passage Mode'),
                  const Spacer(),
                  Switch(
                    value: controller.isPassageModeEnabled.value,
                    onChanged: controller.isPassageModeUpdateInProgress.value
                        ? null
                        : (value) {
                            if (!value) {
                              Get.back();

                              controller.configurePassageMode(
                                enable: false,
                                cyclicConfig: [],
                                autoUnlock: false,
                              );
                            } else {
                              Get.back();
                              _showPassageModeConfigDialog(context);
                            }
                          },
                  ),
                ],
              ),
              if (controller.passageModeConfig.value != null) ...[
                const SizedBox(height: 16),
                const Text('Current Configuration:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (controller.passageModeConfig.value != null &&
                    controller.passageModeConfig.value!.containsKey('cyclicConfig') &&
                    controller.passageModeConfig.value!['cyclicConfig'] is List) ...[
                  for (final config in controller.passageModeConfig.value!['cyclicConfig'])
                    _buildPassageModeConfigItem(config),
                ] else
                  const Text('No passage mode configuration found'),
              ],
            ],
          );
        }),
        actions: [
          TextButton(
            child: const Text('CLOSE'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('CONFIGURE'),
            onPressed: () {
              Navigator.pop(context);
              _showPassageModeConfigDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPassageModeConfigItem(Map<String, dynamic> config) {
    final bool isAllDay = config['isAllDay'] == 1;
    final List<int> weekDays = List<int>.from(config['weekDays'] ?? []);
    final int startTime = config['startTime'] ?? 0;
    final int endTime = config['endTime'] ?? 0;

    final String timeRange = isAllDay ? 'All Day' : '${_formatMinutes(startTime)} - ${_formatMinutes(endTime)}';

    final String days = _formatWeekDays(weekDays);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time: $timeRange'),
          Text('Days: $days'),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  String _formatWeekDays(List<int> days) {
    if (days.isEmpty) return 'None';

    const Map<int, String> dayMap = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };

    return days.map((day) => dayMap[day] ?? '').join(', ');
  }

  void _showPassageModeConfigDialog(BuildContext context) {
    // This would be a more complex dialog for configuring passage mode
    // You might want to create a separate widget for this
    bool enablePassageMode = controller.isPassageModeEnabled.value;
    bool enableAutoUnlock = controller.passageModeConfig.value?['autoUnlock'] == 1;

    // Default configuration for weekly schedule
    final List<Map<String, dynamic>> configurations = [
      {
        'isAllDay': 2, // Not all day
        'startTime': 480, // 8:00 AM
        'endTime': 1080, // 6:00 PM
        'weekDays': [1, 2, 3, 4, 5], // Monday to Friday
      }
    ];

    // If we have existing configurations, use them
    if (controller.passageModeConfig.value != null &&
        controller.passageModeConfig.value!.containsKey('cyclicConfig') &&
        controller.passageModeConfig.value!['cyclicConfig'] is List &&
        (controller.passageModeConfig.value!['cyclicConfig'] as List).isNotEmpty) {
      configurations.clear();
      configurations.addAll(List<Map<String, dynamic>>.from(controller.passageModeConfig.value!['cyclicConfig']));
    }

    // Show a simplified configuration dialog
    // In a real app, you might want a more comprehensive UI for this
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Configure Passage Mode'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Enable Passage Mode'),
                  value: enablePassageMode,
                  onChanged: (value) {
                    setState(() {
                      enablePassageMode = value;
                    });
                  },
                ),

                SwitchListTile(
                  title: const Text('Auto Unlock at Start Time'),
                  subtitle: const Text('Lock will automatically unlock when passage mode starts'),
                  value: enableAutoUnlock,
                  onChanged: (value) {
                    setState(() {
                      enableAutoUnlock = value;
                    });
                  },
                ),

                const SizedBox(height: 16),
                const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Display and allow editing of configurations
                // This is simplified - you would typically use a more comprehensive UI
                // for editing multiple schedules
                for (int i = 0; i < configurations.length; i++)
                  _buildPassageModeConfigEditor(configurations[i], (newConfig) {
                    setState(() {
                      configurations[i] = newConfig;
                    });
                  }),

                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Schedule'),
                  onPressed: () {
                    setState(() {
                      configurations.add({
                        'isAllDay': 2,
                        'startTime': 480,
                        'endTime': 1080,
                        'weekDays': [1, 2, 3, 4, 5],
                      });
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context),
            ),
            Obx(() => TextButton(
                  onPressed: controller.isPassageModeUpdateInProgress.value
                      ? null
                      : () {
                          Navigator.pop(context);
                          controller.configurePassageMode(
                            enable: enablePassageMode,
                            cyclicConfig: configurations,
                            autoUnlock: enableAutoUnlock,
                          );
                        },
                  child: controller.isPassageModeUpdateInProgress.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SAVE'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPassageModeConfigEditor(Map<String, dynamic> config, Function(Map<String, dynamic>) onUpdate) {
    // This is a simplified editor - in a real app, you would make this more comprehensive
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            dense: true,
            title: const Text('All Day'),
            value: config['isAllDay'] == 1,
            onChanged: (value) {
              final newConfig = Map<String, dynamic>.from(config);
              newConfig['isAllDay'] = value ? 1 : 2;
              onUpdate(newConfig);
            },
          ),
          if (config['isAllDay'] != 1) ...[
            ListTile(
              dense: true,
              title: const Text('Start Time'),
              trailing: Text(_formatMinutes(config['startTime'])),
              onTap: () {
                // Here you would show a time picker
              },
            ),
            ListTile(
              dense: true,
              title: const Text('End Time'),
              trailing: Text(_formatMinutes(config['endTime'])),
              onTap: () {
                // Here you would show a time picker
              },
            ),
          ],
          const Divider(),
          const Text('Days of Week', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (int day = 1; day <= 7; day++)
                FilterChip(
                  label: Text(_getDayAbbreviation(day)),
                  selected: (config['weekDays'] as List<dynamic>).contains(day),
                  onSelected: (selected) {
                    final List<int> days = List<int>.from(config['weekDays'] ?? []);
                    if (selected) {
                      if (!days.contains(day)) days.add(day);
                    } else {
                      days.remove(day);
                    }
                    days.sort(); // Keep days in order

                    final newConfig = Map<String, dynamic>.from(config);
                    newConfig['weekDays'] = days;
                    onUpdate(newConfig);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayAbbreviation(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
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
