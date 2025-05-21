import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';
import './create_passcode_controller.dart';
import 'package:intl/intl.dart';

class CreatePasscodeScreen extends GetView<CreatePasscodeController> {
  const CreatePasscodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.arguments != null) {
      controller.lockInfo = Get.arguments;
      controller.lockData = controller.lockInfo?.lockData;
    }

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Create Passcode',
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroSection(context),
              const SizedBox(height: 24),
              _buildPasscodeTypeSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a new passcode for ${controller.lockInfo?.lockAlias ?? "your lock"}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a passcode type that fits your needs. You can create temporary or permanent passcodes for different purposes.',
          ),
        ],
      ),
    );
  }

  Widget _buildPasscodeTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passcode Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPasscodeTypeCard(
          context,
          title: 'One-Time Passcode',
          description: 'Creates a passcode that can only be used once',
          icon: Icons.looks_one,
          iconColor: Colors.purple,
          onTap: () => _showOneTimePasscodeDialog(context),
        ),
        _buildPasscodeTypeCard(
          context,
          title: 'Temporary Passcode',
          description: 'Valid for a limited time period',
          icon: Icons.access_time,
          iconColor: Colors.green,
          onTap: () => _showTemporaryPasscodeDialog(context),
        ),
        _buildPasscodeTypeCard(
          context,
          title: 'Permanent Passcode',
          description: 'Never expires',
          icon: Icons.vpn_key,
          iconColor: Colors.amber,
          onTap: () => _showPermanentPasscodeDialog(context),
        ),
        _buildPasscodeTypeCard(
          context,
          title: 'Custom Passcode',
          description: 'Create your own custom passcode',
          icon: Icons.edit,
          iconColor: Colors.blue,
          onTap: () => _showCustomPasscodeDialog(context),
        ),
      ],
    );
  }

  Widget _buildPasscodeTypeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showOneTimePasscodeDialog(BuildContext context) {
    final nameController = TextEditingController();

    // Calculate default start time (now) and end time (1 day from now)
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create One-Time Passcode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Passcode Name (Optional)',
                hintText: 'e.g., Cleaner, Guest',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This passcode can only be used once. It will be valid starting now and will expire after 24 hours if not used.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          Obx(() => TextButton(
                onPressed: controller.isCreatingPasscode.value
                    ? null
                    : () async {
                        Navigator.pop(context);
                        final result = await controller.getRandomPasscode(
                          keyboardPwdType: 5, // One-time
                          keyboardPwdName: nameController.text.trim(),
                          startDate: now.millisecondsSinceEpoch,
                          endDate: tomorrow.millisecondsSinceEpoch,
                        );

                        if (result != null && result['keyboardPwd'] != null) {
                          _showSuccessDialog(context, result['keyboardPwd']);
                        }
                      },
                child: controller.isCreatingPasscode.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('CREATE'),
              )),
        ],
      ),
    );
  }

  void _showTemporaryPasscodeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final now = DateTime.now();
    DateTime startDate = now;
    DateTime endDate = now.add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Temporary Passcode'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Passcode Name (Optional)',
                    hintText: 'e.g., House Guest, Contractor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Valid from:'),
                    const Spacer(),
                    TextButton(
                      child: Text(DateFormat('MMM dd, yyyy').format(startDate)),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) {
                          setState(() {
                            startDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              startDate.hour,
                              startDate.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Valid to:'),
                    const Spacer(),
                    TextButton(
                      child: Text(DateFormat('MMM dd, yyyy').format(endDate)),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: now.add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) {
                          setState(() {
                            endDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              endDate.hour,
                              endDate.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
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
                  onPressed: controller.isCreatingPasscode.value
                      ? null
                      : () async {
                          Navigator.pop(context);
                          final result = await controller.getRandomPasscode(
                            keyboardPwdType: 3, // Period
                            keyboardPwdName: nameController.text.trim(),
                            startDate: startDate.millisecondsSinceEpoch,
                            endDate: endDate.millisecondsSinceEpoch,
                          );

                          if (result != null && result['keyboardPwd'] != null) {
                            _showSuccessDialog(context, result['keyboardPwd']);
                          }
                        },
                  child: controller.isCreatingPasscode.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('CREATE'),
                )),
          ],
        ),
      ),
    );
  }

  void _showPermanentPasscodeDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Permanent Passcode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Passcode Name (Optional)',
                hintText: 'e.g., Family Member, Roommate',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This passcode will never expire. It can be used repeatedly until it is deleted.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          Obx(() => TextButton(
                onPressed: controller.isCreatingPasscode.value
                    ? null
                    : () async {
                        Navigator.pop(context);
                        final result = await controller.getRandomPasscode(
                          keyboardPwdType: 1, // Permanent
                          keyboardPwdName: nameController.text.trim(),
                          startDate: DateTime.now().millisecondsSinceEpoch,
                        );

                        if (result != null && result['keyboardPwd'] != null) {
                          _showSuccessDialog(context, result['keyboardPwd']);
                        }
                      },
                child: controller.isCreatingPasscode.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('CREATE'),
              )),
        ],
      ),
    );
  }

  void _showCustomPasscodeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final passcodeController = TextEditingController();

    // Default to period (date-range) type
    int selectedType = 3;
    final now = DateTime.now();
    DateTime startDate = now;
    DateTime endDate = now.add(const Duration(days: 30));

    // Type options
    final List<Map<String, dynamic>> typeOptions = [
      {'label': 'One-time', 'value': 5, 'description': 'Can only be used once'},
      {'label': 'Temporary', 'value': 3, 'description': 'Valid for a specific period'},
      {'label': 'Permanent', 'value': 1, 'description': 'Never expires'},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Custom Passcode'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Passcode Name (Optional)',
                    hintText: 'e.g., Mom, Dad, Sister',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Passcode',
                    hintText: 'Enter 4-9 digits',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Passcode Type:', style: TextStyle(fontWeight: FontWeight.bold)),

                // Type selection radio buttons
                for (var option in typeOptions)
                  RadioListTile<int>(
                    title: Text(option['label']),
                    subtitle: Text(option['description']),
                    value: option['value'],
                    groupValue: selectedType,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                  ),

                // Only show date range for temporary passcodes
                if (selectedType == 3) ...[
                  const Divider(),
                  const Text('Valid Period:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text('From:'),
                      const Spacer(),
                      TextButton(
                        child: Text(DateFormat('MMM dd, yyyy').format(startDate)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            setState(() {
                              startDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('To:'),
                      const Spacer(),
                      TextButton(
                        child: Text(DateFormat('MMM dd, yyyy').format(endDate)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: now.add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            setState(() {
                              endDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context),
            ),
            Obx(() => TextButton(
                  onPressed: controller.isCreatingPasscode.value || passcodeController.text.length < 4
                      ? null
                      : () async {
                          if (passcodeController.text.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passcode must be at least 4 digits.'),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);

                          final result = await controller.addCustomPasscode(
                            keyboardPwd: passcodeController.text.trim(),
                            keyboardPwdName: nameController.text.trim(),
                            keyboardPwdType: selectedType,
                            startDate: startDate.millisecondsSinceEpoch,
                            endDate: selectedType == 1 ? null : endDate.millisecondsSinceEpoch,
                          );

                          if (result != null) {
                            _showSuccessDialog(context, passcodeController.text.trim());
                          }
                        },
                  child: controller.isCreatingPasscode.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('CREATE'),
                )),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String passcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Passcode Created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Your new passcode is:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                passcode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Please make note of this passcode. For security reasons, you won\'t be able to view the complete code again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('GO TO PASSCODE LIST'),
            onPressed: () {
              Navigator.pop(context);
              Get.offNamed('/passcode-manager', arguments: controller.lockInfo);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: Colors.blue[50],
            ),
            child: const Text('DONE'),
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
