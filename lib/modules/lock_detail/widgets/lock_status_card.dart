import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_response/ttlock_item_response.dart';

class LockStatusCard extends StatelessWidget {
  final TTLockInitializedItem? lockInfo;
  final int batteryLevel;

  const LockStatusCard({
    super.key,
    required this.lockInfo,
    required this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
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
                    lockInfo?.lockAlias ?? lockInfo?.lockName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (batteryLevel > 0) ...[
                  Column(
                    children: [
                      Icon(
                        _getBatteryIcon(batteryLevel),
                        color: _getBatteryColor(batteryLevel),
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$batteryLevel%',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getBatteryColor(batteryLevel),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
