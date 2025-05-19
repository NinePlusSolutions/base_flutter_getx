import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_list/gateway_list_controller.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttlock.dart';

class GatewayListScreen extends GetView<GatewayListController> {
  const GatewayListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: context.colors.primary,
        title: 'Gateways',
        elevation: 2,
      ),
      body: _buildBody(context),
      floatingActionButton: Obx(() {
        if (controller.isConnected.value) {
          return FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () => controller.disconnectGateway(),
            tooltip: 'Disconnect',
            child: const Icon(Icons.link_off),
          );
        } else if (controller.isScanning.value) {
          return FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () => controller.stopScan(),
            tooltip: 'Stop Scanning',
            child: const Icon(Icons.stop),
          );
        } else {
          return FloatingActionButton(
            onPressed: () => controller.startScan(),
            tooltip: 'Scan for Gateways',
            child: const Icon(Icons.search),
          );
        }
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isConnected.value) {
        return _buildInitializationScreen(context);
      } else {
        return _buildDiscoveryScreen(context);
      }
    });
  }

  Widget _buildDiscoveryScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.isScanning.value) {
              return Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('Scanning for gateways...', style: context.title),
                  ],
                ),
              );
            } else if (controller.discoveredGateways.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.router_outlined, size: 64, color: context.colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'No gateways found',
                      style: context.title,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }
            return Expanded(
              child: ListView.builder(
                itemCount: controller.discoveredGateways.length,
                itemBuilder: (context, index) {
                  final gateway = controller.discoveredGateways[index];
                  return _buildGatewayItem(context, gateway);
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.hasLoadedInitializedGateways.value && controller.initializedGateways.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Account Gateways',
                    style: context.title.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: controller.initializedGateways.length,
                      itemBuilder: (context, index) {
                        final gateway = controller.initializedGateways[index];
                        return _buildInitializedGatewayItem(context, gateway);
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildGatewayItem(BuildContext context, Map<String, dynamic> gateway) {
    String gatewayType = 'Unknown';
    final type = gateway['type'];
    if (type == TTGatewayType.g2) {
      gatewayType = 'G2';
    } else if (type == TTGatewayType.g3) {
      gatewayType = 'G3';
    } else if (type == TTGatewayType.g4) {
      gatewayType = 'G4';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          Icons.router,
          color: context.colors.primary,
          size: 36,
        ),
        title: Text('${gateway['gatewayName']} ($gatewayType)'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MAC: ${gateway['gatewayMac']}'),
            Text('Signal: ${gateway['rssi']} dBm'),
          ],
        ),
        trailing: Obx(() {
          if (controller.isConnecting.value &&
              controller.selectedGateway.value['gatewayMac'] == gateway['gatewayMac']) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          return const Icon(Icons.chevron_right);
        }),
        onTap: () {
          if (!controller.isConnecting.value) {
            controller.connectToGateway(gateway);
          }
        },
      ),
    );
  }

  Widget _buildInitializedGatewayItem(BuildContext context, Map<String, dynamic> gateway) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: const Icon(
          Icons.router,
          color: Colors.green,
          size: 36,
        ),
        title: Text(gateway['gatewayName'] ?? 'Unnamed Gateway'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gateway ID: ${gateway['gatewayId']}'),
            Text('Status: ${gateway['networkStatus'] == 1 ? 'Online' : 'Offline'}'),
          ],
        ),
        trailing: const Icon(Icons.info_outline),
        onTap: () {
          Get.toNamed(
            Routes.gatewayDetail,
            parameters: {
              'id': gateway['gatewayId'].toString(),
            },
          );
        },
      ),
    );
  }

  Widget _buildInitializationScreen(BuildContext context) {
    return Obx(() {
      final gatewayType = controller.selectedGateway.value['type'];
      final isG2Gateway = gatewayType == TTGatewayType.g2;

      String gatewayTypeStr = 'Unknown';
      if (gatewayType == TTGatewayType.g2) {
        gatewayTypeStr = 'G2';
      } else if (gatewayType == TTGatewayType.g3) {
        gatewayTypeStr = 'G3';
      } else if (gatewayType == TTGatewayType.g4) {
        gatewayTypeStr = 'G4';
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 24.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected Gateway',
                        style: context.title.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${controller.selectedGateway.value['gatewayName']}'),
                      Text('MAC: ${controller.selectedGateway.value['gatewayMac']}'),
                      Text('Type: $gatewayTypeStr'),
                      Text('Signal: ${controller.selectedGateway.value['rssi']} dBm'),
                    ],
                  ),
                ),
              ),
              Text(
                'Gateway Setup',
                style: context.title.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.gatewayNameController,
                decoration: InputDecoration(
                  labelText: 'Gateway Name',
                  hintText: 'Enter a name for this gateway',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              if (isG2Gateway) ...[
                Text(
                  'WiFi Setup (Required for G2)',
                  style: context.title.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.wifiNameController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'WiFi Network',
                    hintText: 'Select a WiFi network',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isScanningWifi.value ? Icons.stop : Icons.wifi_find,
                        color: context.colors.primary,
                      ),
                      onPressed: controller.isScanningWifi.value ? null : () => controller.scanWifiNetworks(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.wifiPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'WiFi Password',
                    hintText: 'Enter WiFi password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.isScanningWifi.value)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Scanning for WiFi networks...'),
                      ],
                    ),
                  )
                else if (controller.discoveredWifiNetworks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Networks',
                        style: context.title.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: controller.discoveredWifiNetworks.length,
                          itemBuilder: (context, index) {
                            final wifi = controller.discoveredWifiNetworks[index];
                            return ListTile(
                              title: Text(wifi['name']),
                              subtitle: Text('Signal: ${wifi['rssi']} dBm'),
                              trailing: const Icon(Icons.wifi),
                              onTap: () => controller.selectWifiNetwork(wifi['name']),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: controller.isInitializing.value ? null : () => controller.initializeGateway(),
                  child: controller.isInitializing.value
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Text('Initializing...'),
                          ],
                        )
                      : const Text('Initialize Gateway'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
