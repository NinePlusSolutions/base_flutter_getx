import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/checkin/checkin_controller.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/checkin/checkin_history_widget.dart';
import 'package:get/get.dart';

class CheckinDemoPage extends StatelessWidget {
  const CheckinDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckinController>(
      init: CheckinController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Checkin Demo'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => Get.to(() => CheckinHistoryWidget()),
              icon: const Icon(Icons.history),
              tooltip: 'View History',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Obx(() => Text(
                            controller.statusText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      const SizedBox(height: 8),
                      Obx(() {
                        final lastTime = controller.lastActionTime;
                        return Text(
                          lastTime != null ? 'Last action: $lastTime' : 'No actions yet',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => controller.isLoading.value
                          ? const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Getting location...'),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        controller.currentAddress.value.isEmpty
                                            ? 'Location not available'
                                            : controller.currentAddress.value,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                if (controller.currentPosition.value != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.gps_fixed, size: 16, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${controller.currentPosition.value!.latitude.toStringAsFixed(6)}, ${controller.currentPosition.value!.longitude.toStringAsFixed(6)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            )),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: controller.getCurrentLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Location'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
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
                        decoration: const InputDecoration(
                          hintText: 'Add any notes for this checkin...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action Buttons
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              controller.canCheckin && !controller.isLoading.value ? controller.performCheckin : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: controller.isProcessing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt),
                          label: Text(controller.isProcessing ? 'Processing...' : 'Check In'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              controller.canCheckout && !controller.isLoading.value ? controller.performCheckout : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: controller.isProcessing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt),
                          label: Text(controller.isProcessing ? 'Processing...' : 'Check Out'),
                        ),
                      ),
                    ],
                  )),

              const SizedBox(height: 16),

              // History Summary
              Obx(() {
                final count = controller.capturedImages.length;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('Captured Images: $count'),
                    subtitle: count > 0 ? const Text('Tap to view history') : const Text('No images captured yet'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.to(() => CheckinHistoryWidget()),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
