import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_response/ttlock_item_response.dart';
import 'package:flutter_getx_boilerplate/modules/lock_list/lock_list_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttlock.dart';

class LockListScreen extends GetView<LockListController> {
  const LockListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: context.colors.primary,
        title: 'Lock',
        elevation: 2,
      ),
      body: _buildBody(context),
      floatingActionButton: Obx(() {
        return FloatingActionButton(
          backgroundColor: controller.isScanning.value ? Colors.orange : context.colors.primary,
          onPressed: controller.isScanning.value ? controller.stopScan : controller.startScan,
          tooltip: controller.isScanning.value ? 'Stop Scanning' : 'Scan for Locks',
          child: Icon(
            controller.isScanning.value ? Icons.stop : Icons.search,
            color: context.colors.surface,
          ),
        );
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(context),
        Expanded(
          child: Obx(() {
            if (controller.currentTab.value == 0) {
              return _buildInitializedLocksTab(context);
            } else {
              return _buildScannedLocksTab(context);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(
            context,
            0,
            'My Locks',
            Icons.lock,
            controller.initializedLocks.length,
          ),
          _buildTabItem(
            context,
            1,
            'Scan Results',
            Icons.bluetooth_searching,
            controller.scannedLocks.length,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    int tabIndex,
    String title,
    IconData icon,
    int count,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => controller.switchTab(tabIndex),
        child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: controller.currentTab.value == tabIndex ? context.colors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: controller.currentTab.value == tabIndex ? context.colors.primary : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: controller.currentTab.value == tabIndex ? context.colors.primary : Colors.grey,
                      fontWeight: controller.currentTab.value == tabIndex ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildInitializedLocksTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingInitializedLocks.value) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your locks...', style: TextStyle(fontSize: 16)),
            ],
          ),
        );
      }

      if (controller.initializedLocks.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No initialized locks found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the scan button to find new locks',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadInitializedLocks,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: controller.initializedLocks.length,
          itemBuilder: (context, index) {
            return _buildInitializedLockItem(
              context,
              controller.initializedLocks[index],
            );
          },
        ),
      );
    });
  }

  Widget _buildScannedLocksTab(BuildContext context) {
    return Obx(() {
      if (controller.isScanning.value && controller.scannedLocks.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Scanning for locks...',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Text(
                'Please touch the keyboard of lock to wake it up',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      if (!controller.isScanning.value && controller.scannedLocks.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No new locks found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the scan button to find nearby locks',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(top: controller.isScanning.value ? 48 : 12, bottom: 12),
            itemCount: controller.scannedLocks.length,
            itemBuilder: (context, index) {
              return _buildScannedLockItem(context, controller.scannedLocks[index]);
            },
          ),
          if (controller.isScanning.value)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.blue.withValues(alpha: 0.9),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Scanning...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildInitializedLockItem(BuildContext context, TTLockInitializedItem lock) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.onInitializedLockTap(lock),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.teal,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lock.lockAlias.isNotEmpty ? lock.lockAlias : lock.lockName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'MAC: ${lock.lockMac}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Hiển thị pin
                  _buildBatteryIndicator(lock.electricQuantity),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (lock.hasGateway == 1) ...[
                    _buildInfoChip(Icons.router, 'Gateway connected', Colors.teal),
                    const SizedBox(width: 8),
                  ],
                  _buildInfoChip(Icons.verified_user, 'Initialzed', Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannedLockItem(BuildContext context, TTLockScanModel lock) {
    final bool isInited = lock.isInited;
    final Color cardColor = isInited ? Colors.grey.shade50 : Colors.white;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isInited ? null : () => controller.onScannedLockTap(lock),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      lock.isInited ? Icons.lock : Icons.lock_open,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lock.lockName.isNotEmpty ? lock.lockName : 'New Lock',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MAC: ${lock.lockMac}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Hiển thị pin nếu có
                  lock.electricQuantity > 0 ? _buildBatteryIndicator(lock.electricQuantity) : Container(),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (lock.lockSwitchState != TTLockSwitchState.unknow) ...[
                    _buildInfoChip(
                      lock.lockSwitchState == TTLockSwitchState.lock ? Icons.lock : Icons.lock_open,
                      lock.lockSwitchState == TTLockSwitchState.lock ? 'Locked' : 'Unlocked',
                      lock.lockSwitchState == TTLockSwitchState.lock ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!lock.isInited) _buildInfoChip(Icons.new_releases, 'New Device', Colors.orange),
                  if (!isInited) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryIndicator(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBatteryColor(level).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getBatteryIcon(level),
            size: 16,
            color: _getBatteryColor(level),
          ),
          const SizedBox(width: 4),
          Text(
            '$level%',
            style: TextStyle(
              fontSize: 12,
              color: _getBatteryColor(level),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
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
