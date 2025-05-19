import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/lock_list/lock_list_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';

class LockListScreen extends GetView<LockListController> {
  const LockListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: context.colors.primary,
        title: 'My Smart Locks',
        elevation: 2,
      ),
      body: _buildBody(context),
      floatingActionButton: Obx(() {
        if (controller.isScanning.value) {
          return FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: controller.stopScan,
            tooltip: 'Stop Scanning',
            child: const Icon(Icons.stop),
          );
        } else {
          return FloatingActionButton(
            onPressed: controller.startScan,
            tooltip: 'Scan for Locks',
            child: const Icon(Icons.search),
          );
        }
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  text: "Account Locks",
                  onPressed: controller.showAllInitializedLocks,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingInitializedLocks.value) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading locks...', style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            if (controller.discoveredLocks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No locks found',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the scan button to find nearby locks',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            return _buildLockList(context);
          }),
        ),
      ],
    );
  }

  Widget _buildLockList(BuildContext context) {
    return ListView.builder(
      itemCount: controller.discoveredLocks.length,
      itemBuilder: (context, index) {
        final lock = controller.discoveredLocks[index];
        final bool isOnlineOnly = lock['isOnlineOnly'] == true;
        final bool isInitialized = lock['isInited'] == true;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => controller.navigateToLockControl(lock),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isOnlineOnly ? Colors.teal.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isInitialized ? Icons.lock : Icons.lock_open,
                          color: isOnlineOnly ? Colors.teal : Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lock['lockAlias'] ?? lock['lockName'] ?? 'Unknown Lock',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MAC: ${lock['lockMac']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      isOnlineOnly
                          ? const Icon(Icons.cloud, color: Colors.teal)
                          : const Icon(Icons.bluetooth, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (lock['electricQuantity'] != null && lock['electricQuantity'] > 0) ...[
                        Icon(
                          _getBatteryIcon(lock['electricQuantity']),
                          size: 16,
                          color: _getBatteryColor(lock['electricQuantity']),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lock['electricQuantity']}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (lock['hasGateway'] == true) ...[
                        const Icon(Icons.router, size: 16, color: Colors.teal),
                        const SizedBox(width: 4),
                        const Text('Gateway', style: TextStyle(fontSize: 12, color: Colors.teal)),
                        const SizedBox(width: 12),
                      ],
                      if (isInitialized) ...[
                        const Icon(Icons.verified_user, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        const Text('Initialized', style: TextStyle(fontSize: 12, color: Colors.green)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
