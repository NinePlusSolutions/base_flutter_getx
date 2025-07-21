import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/checkin/checkin_controller.dart';
import 'package:get/get.dart';

class CheckinHistoryWidget extends StatelessWidget {
  final CheckinController controller = Get.find<CheckinController>();

  CheckinHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkin History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.checkinHistory.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No checkin records yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.checkinHistory.length,
          itemBuilder: (context, index) {
            final record = controller.checkinHistory[index];
            return _buildHistoryCard(record);
          },
        );
      }),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    final timestamp = DateTime.parse(record['timestamp']);
    final formattedTime = _formatDateTime(timestamp);
    final isCheckin = record['type'] == 'checkin';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay
          GestureDetector(
            onTap: () => controller.viewImageFullScreen(record),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: MemoryImage(base64Decode(record['imageBase64'])),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Type badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCheckin ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          record['type'].toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // View icon
                    const Positioned(
                      bottom: 12,
                      right: 12,
                      child: Icon(Icons.fullscreen, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Record details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                _buildDetailRow(Icons.access_time, formattedTime),
                const SizedBox(height: 8),
                
                // Location
                _buildDetailRow(Icons.location_on, record['address'] ?? 'Unknown Location'),
                const SizedBox(height: 8),
                
                // GPS coordinates
                _buildDetailRow(
                  Icons.gps_fixed,
                  '${record['latitude']?.toStringAsFixed(6)}, ${record['longitude']?.toStringAsFixed(6)}',
                  textStyle: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
                
                // Notes (if available)
                if (record['notes'] != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.note, record['notes']),
                ],

                // Connection status
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      record['isOnline'] == true ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record['isOnline'] == true ? 'Online' : 'Offline',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.viewImageFullScreen(record),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(record),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {TextStyle? textStyle}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: textStyle ?? const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(Map<String, dynamic> record) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteRecord(record['id']);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}