import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/checkin/checkin_controller.dart';
import 'package:flutter_getx_boilerplate/shared/extension/extension.dart';
import 'package:flutter_getx_boilerplate/modules/checkin/widgets/checkin_history_widget.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/widgets.dart';
import 'package:get/get.dart';

import '../issue_report/widgets/location_card_widget.dart';

class CheckinScreen extends GetView<CheckinController> {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBarWidget(
        title: 'Checkin Management',
        backgroundColor: context.colors.secondary,
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
                color: controller.isOnline.value ? Colors.green : Colors.red,
              ),
              onPressed: () => _showConnectionInfo(context),
            );
          }),
          IconButton(
            icon: const Icon(Icons.history),
            color: context.colors.surface,
            onPressed: () {
              Get.to(
                () => CheckinHistoryWidget(),
                transition: Transition.rightToLeft,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => controller.refreshLocation(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 20),
                _buildLocationCard(),
                const SizedBox(height: 20),
                _buildNotesSection(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(),
            size: 48,
            color: _getStatusColor(),
          ),
          const SizedBox(height: 12),
          Text(
            controller.statusText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(),
            ),
          ),
          if (controller.lastActionTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last action: ${controller.lastActionTime}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          // Tracking information integrated into status card
          if (controller.isTrackingEnabled.value) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.timer, size: 20, color: Colors.green),
                      const SizedBox(height: 4),
                      Text(
                        controller.trackingDurationText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'Duration',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      const Icon(Icons.location_history, size: 20, color: Colors.blue),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.trackingHistory.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const Text(
                        'Points',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      Icon(
                        controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
                        size: 20,
                        color: controller.isOnline.value ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.isOnline.value ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: controller.isOnline.value ? Colors.green : Colors.orange,
                        ),
                      ),
                      const Text(
                        'Status',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'Location tracking will start after checkin',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showConnectionInfo(BuildContext context) {
    final connectionInfo = controller.getConnectionInfo();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
                  color: controller.isOnline.value ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.isOnline.value ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: controller.isOnline.value ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Connection Type: ${controller.connectionType.value}'),
            if (connectionInfo['lastConnectedTime'] != null) ...[
              const SizedBox(height: 8),
              Text('Last Connected: ${DateTime.parse(connectionInfo['lastConnectedTime']).toString()}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return LocationCardWidget(
      position: controller.currentPosition.value,
      address: controller.currentAddress.value,
      isLoading: controller.isLoading.value,
      onRefresh: controller.refreshLocation,
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.notes,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any notes for this checkin...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.canCheckin && !controller.isLoading.value ? controller.performCheckin : null,
            icon: const Icon(Icons.login),
            label: const Text('Check In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.canCheckout && !controller.isLoading.value ? controller.performCheckout : null,
            icon: const Icon(Icons.logout),
            label: const Text('Check Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (controller.checkinStatus.value) {
      case CheckinStatus.notCheckedIn:
        return Colors.grey;
      case CheckinStatus.checkedIn:
        return Colors.green;
      case CheckinStatus.processing:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (controller.checkinStatus.value) {
      case CheckinStatus.notCheckedIn:
        return Icons.access_time;
      case CheckinStatus.checkedIn:
        return Icons.check_circle;
      case CheckinStatus.processing:
        return Icons.hourglass_empty;
    }
  }
}
