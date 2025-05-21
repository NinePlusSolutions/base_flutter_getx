import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_keyboard_pwd/ttlock_keyboard_pwd_model.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';
import './passcode_manager_controller.dart';
import 'package:intl/intl.dart';

class PasscodeManagerScreen extends GetView<PasscodeManagerController> {
  const PasscodeManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.arguments != null) {
      controller.lockInfo = Get.arguments;
      controller.lockData = controller.lockInfo?.lockData;
      Future.delayed(const Duration(milliseconds: 300), () {
        controller.loadPasscodes();
      });
    }

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Passcodes',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.createPasscode, arguments: controller.lockInfo),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingPasscodes.value && controller.passcodes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.passcodes.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildPasscodeList(context);
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.vpn_key_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No passcodes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a passcode to allow access to your lock',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Passcode'),
            onPressed: () => Get.toNamed('/create-passcode', arguments: controller.lockInfo),
          ),
        ],
      ),
    );
  }

  Widget _buildPasscodeList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadPasscodes(showLoading: false);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() => Text(
                  'Total passcodes: ${controller.totalPasscodes}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.passcodes.length,
              itemBuilder: (context, index) {
                final passcode = controller.passcodes[index];
                return _buildPasscodeItem(context, passcode);
              },
            ),
          ),
          // Pagination controls if needed
          if (controller.totalPages.value > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: controller.currentPage.value > 1
                        ? () => controller.loadPasscodes(page: controller.currentPage.value - 1)
                        : null,
                  ),
                  Text('${controller.currentPage.value} / ${controller.totalPages.value}'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: controller.currentPage.value < controller.totalPages.value
                        ? () => controller.loadPasscodes(page: controller.currentPage.value + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasscodeItem(BuildContext context, TTLockKeyboardPwdModel passcode) {
    // Format dates
    final startDate = passcode.startDate > 0
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(passcode.startDate))
        : 'Permanent';

    final endDate = passcode.endDate > 0
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(passcode.endDate))
        : 'No expiration';

    // Determine passcode type text and icon
    String typeText;
    IconData typeIcon;
    switch (passcode.keyboardPwdType) {
      case 1:
        typeText = 'Permanent';
        typeIcon = Icons.vpn_key;
        break;
      case 2:
        typeText = 'Temporary';
        typeIcon = Icons.timer;
        break;
      case 3:
        typeText = 'Period';
        typeIcon = Icons.date_range;
        break;
      case 4:
        typeText = 'Cyclic';
        typeIcon = Icons.loop;
        break;
      case 5:
        typeText = 'One-time';
        typeIcon = Icons.looks_one;
        break;
      default:
        typeText = 'Unknown';
        typeIcon = Icons.help_outline;
    }

    // Check if passcode has expired
    final now = DateTime.now().millisecondsSinceEpoch;
    final bool isExpired = passcode.endDate > 0 && passcode.endDate < now;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPasscodeDetails(context, passcode),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, color: isExpired ? Colors.grey : Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      passcode.keyboardPwdName.isNotEmpty
                          ? passcode.keyboardPwdName
                          : 'Passcode #${passcode.keyboardPwdId}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.grey[300] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      typeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired ? Colors.grey[700] : Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                passcode.keyboardPwd,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Valid: $startDate → $endDate',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              if (isExpired)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Expired',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasscodeDetails(BuildContext context, TTLockKeyboardPwdModel passcode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Passcode Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              _buildDetailRow('Name', passcode.keyboardPwdName.isNotEmpty ? passcode.keyboardPwdName : 'Untitled'),
              _buildDetailRow('Passcode', passcode.keyboardPwd),
              _buildDetailRow('Type', _getTypeText(passcode.keyboardPwdType)),
              _buildDetailRow('Valid From', _formatDate(passcode.startDate)),
              _buildDetailRow('Valid To', passcode.endDate > 0 ? _formatDate(passcode.endDate) : 'No expiration'),
              _buildDetailRow('Created', _formatDate(passcode.startDate)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('EDIT'),
                      onPressed: () {
                        Navigator.pop(context);
                        _showRenamePasscodeDialog(context, passcode);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('DELETE'),
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmationDialog(context, passcode);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeText(int type) {
    switch (type) {
      case 1:
        return 'Permanent';
      case 2:
        return 'Temporary';
      case 3:
        return 'Period';
      case 4:
        return 'Cyclic';
      case 5:
        return 'One-time';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(int milliseconds) {
    if (milliseconds <= 0) return 'Not set';
    return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
  }

  void _showDeleteConfirmationDialog(BuildContext context, TTLockKeyboardPwdModel passcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Passcode?'),
        content: Text(
          'Are you sure you want to delete the passcode "${passcode.keyboardPwdName.isNotEmpty ? passcode.keyboardPwdName : passcode.keyboardPwd}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          Obx(() => TextButton(
                onPressed: controller.isDeletingPasscode.value
                    ? null
                    : () {
                        Navigator.pop(context);
                        controller.deletePasscode(passcode.keyboardPwdId);
                      },
                child: controller.isDeletingPasscode.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('DELETE', style: TextStyle(color: Colors.red)),
              )),
        ],
      ),
    );
  }

  void _showRenamePasscodeDialog(BuildContext context, TTLockKeyboardPwdModel passcode) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = passcode.keyboardPwdName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Passcode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Passcode Name',
                hintText: 'Enter a descriptive name',
                border: OutlineInputBorder(),
              ),
              maxLength: 30,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          Obx(() => TextButton(
                onPressed: controller.isChangingPasscode.value
                    ? null
                    : () {
                        Navigator.pop(context);
                        controller.changePasscodeName(passcode.keyboardPwdId, nameController.text.trim());
                      },
                child: controller.isChangingPasscode.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SAVE'),
              )),
        ],
      ),
    );
  }
}
