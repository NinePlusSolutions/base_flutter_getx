import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/checkin/checkin_controller.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_tracking_service.dart';
import 'package:get/get.dart';

class LocationTrackingWidget extends StatelessWidget {
  final CheckinController controller;

  const LocationTrackingWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshLocation(),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isTrackingEnabled.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_disabled,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Location tracking is not active',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrackingOverview(),
              const SizedBox(height: 20),
              _buildDetailedStats(),
              const SizedBox(height: 20),
              _buildLocationHistory(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTrackingOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracking Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOverviewItem(
              'Status',
              controller.trackingStatusText,
              Icons.info,
              _getStatusColor(),
            ),
            const SizedBox(height: 12),
            _buildOverviewItem(
              'Connection',
              '${controller.connectionType.value} ${controller.isOnline.value ? '(Online)' : '(Offline)'}',
              controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
              controller.isOnline.value ? Colors.green : Colors.red,
            ),
            if (controller.currentTrackingData.value != null) ...[
              const SizedBox(height: 12),
              _buildOverviewItem(
                'Current Location',
                controller.currentAddress.value,
                Icons.location_on,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildOverviewItem(
                'GPS Coordinates',
                '${controller.currentPosition.value!.latitude.toStringAsFixed(6)}, ${controller.currentPosition.value!.longitude.toStringAsFixed(6)}',
                Icons.gps_fixed,
                Colors.purple,
              ),
              const SizedBox(height: 12),
              _buildOverviewItem(
                'Accuracy',
                '±${controller.currentPosition.value!.accuracy.toStringAsFixed(1)}m',
                Icons.my_location,
                Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats() {
    final stats = controller.getTrackingStatistics();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracking Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Distance',
                    '${(stats['totalDistance'] / 1000).toStringAsFixed(2)} km',
                    Icons.straighten,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Duration',
                    controller.trackingStatusText.contains('(')
                        ? controller.trackingStatusText.split('(')[1].replaceAll(')', '')
                        : '00:00:00',
                    Icons.timer,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Location Points',
                    '${stats['locationCount']}',
                    Icons.my_location,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Speed',
                    '${(stats['averageSpeed'] * 3.6).toStringAsFixed(1)} km/h',
                    Icons.speed,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            if (stats['maxSpeed'] > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Max Speed',
                      '${(stats['maxSpeed'] * 3.6).toStringAsFixed(1)} km/h',
                      Icons.fast_forward,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()), // Empty space for balance
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Location History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.trackingHistory.length} points',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.trackingHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No location history available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.trackingHistory.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final locationData = controller.trackingHistory[index];
                  return _buildLocationHistoryItem(locationData, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHistoryItem(LocationTrackingData locationData, int index) {
    final timestamp = locationData.timestamp;
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: index == 0 ? Colors.green : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: locationData.isOnline ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        locationData.isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  locationData.address,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.gps_fixed, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${locationData.position.latitude.toStringAsFixed(6)}, ${locationData.position.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.my_location, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '±${locationData.position.accuracy.toStringAsFixed(1)}m',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (!controller.isTrackingEnabled.value) return Colors.grey;
    return Colors.green;
  }
}
