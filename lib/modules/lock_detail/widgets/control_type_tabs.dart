import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/lock_detail/lock_detail_controller.dart';
import 'package:get/get.dart';

class ControlTypeTabs extends GetView<LockDetailController> {
  const ControlTypeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildControlTab(
                  context: context,
                  title: 'Remote',
                  icon: Icons.wifi,
                  isSelected: controller.selectedControlType.value == 'remote',
                  onTap: () => controller.setControlType('remote'),
                )),
          ),
          Expanded(
            child: Obx(() => _buildControlTab(
                  context: context,
                  title: 'Bluetooth',
                  icon: Icons.bluetooth,
                  isSelected: controller.selectedControlType.value == 'bluetooth',
                  onTap: () => controller.setControlType('bluetooth'),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildControlTab({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
