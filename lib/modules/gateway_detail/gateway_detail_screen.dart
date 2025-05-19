import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_detail/gateway_detail_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';

class GatewayDetailScreen extends GetView<GatewayDetailController> {
  const GatewayDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: context.colors.primary,
        title: 'Gateway Details',
        elevation: 2,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.gatewayDetail.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load gateway details',
                  style: context.title,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadGatewayDetail(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final detail = controller.gatewayDetail.value;
        final isOnline = detail['isOnline'] == 1;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gateway Status Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gateway Status',
                            style: context.title.copyWith(fontWeight: FontWeight.bold),
                          ),
                          _buildStatusIndicator(isOnline),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Status', isOnline ? 'Online' : 'Offline'),
                      _buildInfoRow('Connected Locks', '${detail['lockNum']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Gateway Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gateway Information',
                        style: context.title.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Gateway ID', '${detail['gatewayId']}'),
                      _buildInfoRow('Name', detail['gatewayName'] ?? 'Not Set'),
                      _buildInfoRow('MAC Address', detail['gatewayMac'] ?? 'Not Available'),
                      _buildInfoRow('Version', _getVersionText(detail['gatewayVersion'])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Network Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network Information',
                        style: context.title.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Network Name', detail['networkName'] ?? 'Not Available'),
                      _buildInfoRow('Network MAC', detail['networkMac'] ?? 'Not Available'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.showRenameDialog(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Rename'),
                  ),
                  Obx(() => ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: controller.isDeleting.value 
                        ? null 
                        : () => _showDeleteConfirmation(context),
                    icon: controller.isDeleting.value
                        ? const SizedBox(
                            width: 16, 
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete),
                    label: const Text('Delete'),
                  )),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusIndicator(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline ? Colors.green.shade700 : Colors.grey.shade400,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: isOnline ? Colors.green.shade700 : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getVersionText(int? version) {
    switch (version) {
      case 1:
        return 'G1';
      case 2:
        return 'G2';
      case 3:
        return 'G3 (Wired)';
      case 4:
        return 'G4 (4G)';
      default:
        return 'Unknown';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Gateway'),
        content: const Text('Are you sure you want to delete this gateway? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteGateway();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}