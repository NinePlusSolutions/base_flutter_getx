import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/checkin/checkin_controller.dart';
import 'package:flutter_getx_boilerplate/shared/constants/colors.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CheckinScreen extends GetView<CheckinController> {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkin Management'),
        backgroundColor: ColorConstants.highlightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => controller.getCurrentLocation(),
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
                const SizedBox(height: 30),
                _buildHistorySection(),
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
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: controller.isLoading.value ? null : controller.getCurrentLocation,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.currentAddress.value.isNotEmpty)
            Text(
              controller.currentAddress.value,
              style: const TextStyle(fontSize: 14),
            )
          else
            const Text(
              'Location not available. Tap refresh to get current location.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (controller.currentPosition.value != null) ...[
            const SizedBox(height: 8),
            Text(
              'GPS: ${controller.currentPosition.value!.latitude.toStringAsFixed(6)}, ${controller.currentPosition.value!.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
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

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full history page
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.capturedImages.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No checkin history available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...controller.capturedImages.take(5).map((imageData) {
            final timestamp = DateTime.parse(imageData['timestamp']);
            final formattedTime =
                '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    imageData['type'] == 'checkin' ? Icons.login : Icons.logout,
                    color: imageData['type'] == 'checkin' ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          imageData['type'] == 'checkin' ? 'Check In' : 'Check Out',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (imageData['address'] != null && imageData['address'].isNotEmpty)
                          Text(
                            imageData['address'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo, color: Colors.blue),
                    onPressed: () {
                      // Show captured image
                      _showImageDialog(imageData);
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _showImageDialog(Map<String, dynamic> imageData) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    imageData['type'] == 'checkin' ? 'Check In Photo' : 'Check Out Photo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(imageData['imageBase64']),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.error, size: 48),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageData['address'] != null) Text('Location: ${imageData['address']}'),
                  const SizedBox(height: 4),
                  Text(
                      'GPS: ${imageData['latitude']?.toStringAsFixed(6)}, ${imageData['longitude']?.toStringAsFixed(6)}'),
                  const SizedBox(height: 4),
                  Text('Time: ${DateTime.parse(imageData['timestamp']).toString().substring(0, 19)}'),
                  if (imageData['notes'] != null) ...[
                    const SizedBox(height: 4),
                    Text('Notes: ${imageData['notes']}'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
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
