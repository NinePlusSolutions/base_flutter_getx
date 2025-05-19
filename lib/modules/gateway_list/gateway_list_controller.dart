import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:flutter_getx_boilerplate/shared/utils/logger.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttgateway.dart';
import 'package:ttlock_flutter/ttlock.dart';

import '../base/base_controller.dart';

class GatewayListController extends BaseController<TTLockRepository> {
  final RxBool isScanning = false.obs;
  final RxList<Map<String, dynamic>> discoveredGateways = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> initializedGateways = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingInitializedGateways = false.obs;
  final RxBool hasLoadedInitializedGateways = false.obs;
  final RxBool needRefreshOnBack = false.obs;

  // Gateway connection states
  final RxBool isConnecting = false.obs;
  final RxBool isConnected = false.obs;
  final RxString connectedGatewayMac = "".obs;

  // WiFi scanning states
  final RxBool isScanningWifi = false.obs;
  final RxList<Map<String, dynamic>> discoveredWifiNetworks = <Map<String, dynamic>>[].obs;

  // Form controllers
  final wifiNameController = TextEditingController();
  final wifiPasswordController = TextEditingController();
  final gatewayNameController = TextEditingController(text: 'My Gateway');

  // Selected gateway
  final Rx<Map<String, dynamic>> selectedGateway = Rx<Map<String, dynamic>>({});

  // Gateway initialization state
  final RxBool isInitializing = false.obs;

  // IP configuration state
  final RxBool isConfiguringIp = false.obs;

  GatewayListController(super.repository);

  @override
  void onInit() {
    super.onInit();
    ever(needRefreshOnBack, (needRefresh) {
      if (needRefresh) {
        loadInitializedGateways();
        needRefreshOnBack.value = false;
      }
    });
    loadInitializedGateways();
  }

  @override
  void onClose() {
    if (isScanning.value) {
      stopScan();
    }
    if (isConnected.value) {
      disconnectGateway();
    }
    wifiNameController.dispose();
    wifiPasswordController.dispose();
    gatewayNameController.dispose();
    super.onClose();
  }

  Future<void> loadInitializedGateways() async {
    if (!await repository.isAuthenticated()) {
      AppLogger.i('User not authenticated, skipping initialized gateways loading');
      return;
    }

    if (isLoadingInitializedGateways.value) return;

    isLoadingInitializedGateways.value = true;
    AppLogger.i('Loading initialized gateways from account');

    try {
      final response = await repository.getGatewayList(pageSize: 50);

      initializedGateways.clear();

      if (response['list'] != null && response['list'] is List) {
        for (var gateway in response['list']) {
          initializedGateways.add(gateway);
        }
      }

      hasLoadedInitializedGateways.value = true;
      AppLogger.i('Loaded ${initializedGateways.length} initialized gateways from account');
    } catch (e) {
      String errorMessage = 'Failed to load initialized gateways';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }

      AppLogger.e('Failed to load initialized gateways: $e');

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoadingInitializedGateways.value = false;
    }
  }

  Future<void> initializeGateway() async {
    if (!isConnected.value || isInitializing.value) return;

    try {
      final gatewayType = selectedGateway.value['type'] as TTGatewayType;
      final String gatewayName = gatewayNameController.text.trim();

      if (gatewayName.isEmpty) {
        throw ErrorResponse(message: 'Gateway name cannot be empty');
      }

      final userInfo = await repository.getUserInfo();
      AppLogger.i('User info from TTLock API: $userInfo');

      final uid = userInfo['uid'];

      if (uid == null) {
        throw ErrorResponse(message: 'Could not retrieve user ID from TTLock API');
      }

      AppLogger.i('Retrieved TTLock user ID: $uid (${uid.runtimeType})');

      // For G2 gateway, we need WiFi credentials
      if (gatewayType == TTGatewayType.g2) {
        final String wifiName = wifiNameController.text.trim();
        final String wifiPassword = wifiPasswordController.text;

        if (wifiName.isEmpty) {
          throw ErrorResponse(message: 'WiFi name cannot be empty');
        }

        await _initializeG2Gateway(gatewayName, wifiName, wifiPassword, uid);
      } else {
        // For G3 and G4 gateways
        await _initializeG3G4Gateway(gatewayName, uid);
      }
    } on ErrorResponse catch (e) {
      Get.snackbar(
        'Initialization Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } catch (e) {
      AppLogger.e('Error initializing gateway: $e');
      Get.snackbar(
        'Initialization Failed',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _initializeG2Gateway(
    String gatewayName,
    String wifiName,
    String wifiPassword,
    int uid,
  ) async {
    isInitializing.value = true;

    try {
      // Get the actual password from storage service
      final ttlockPassword = 'Abc123!@#';
      if (ttlockPassword.isEmpty) {
        throw ErrorResponse(message: 'TTLock password not found');
      }

      AppLogger.i('Initializing G2 gateway with WiFi: $wifiName');

      // Prepare initialization parameters - CORRECTED FORMAT
      final Map<String, dynamic> initParams = {
        'wifi': wifiName,
        'wifiPassword': wifiPassword,
        // Convert type to int to ensure correct formatting
        'type':
            selectedGateway.value['type'] is int ? selectedGateway.value['type'] : selectedGateway.value['type'].index,
        'gatewayName': gatewayName,
        'uid': uid,
        'ttlockLoginPassword': ttlockPassword,
      };

      _performGatewayInitialization(initParams);
    } catch (e) {
      isInitializing.value = false;
      rethrow;
    }
  }

  Future<void> _initializeG3G4Gateway(String gatewayName, int uid) async {
    isInitializing.value = true;

    try {
      final ttlockPassword = 'Abc123!@#';
      if (ttlockPassword.isEmpty) {
        throw ErrorResponse(message: 'TTLock password not found');
      }

      AppLogger.i('Initializing G3/G4 gateway');

      // Prepare initialization parameters - CORRECTED FORMAT
      final Map<String, dynamic> initParams = {
        // Convert type to int to ensure correct formatting
        'type':
            selectedGateway.value['type'] is int ? selectedGateway.value['type'] : selectedGateway.value['type'].index,
        'gatewayName': gatewayName,
        'uid': uid, // Convert to integer if possible
        'ttlockLoginPassword': ttlockPassword,
      };

      _performGatewayInitialization(initParams);
    } catch (e) {
      isInitializing.value = false;
      rethrow;
    }
  }

  void startScan() {
    if (isScanning.value) return;

    isScanning.value = true;
    discoveredGateways.clear();

    AppLogger.i('Starting gateway scan');
    TTGateway.startScan((scanModel) {
      AppLogger.i('Found gateway: ${scanModel.gatewayName}, MAC: ${scanModel.gatewayMac}, Type: ${scanModel.type}');

      if (scanModel.gatewayMac.isNotEmpty) {
        final gatewayInfo = {
          'gatewayMac': scanModel.gatewayMac,
          'gatewayName': scanModel.gatewayName.isNotEmpty ? scanModel.gatewayName : 'Unknown Gateway',
          'rssi': scanModel.rssi,
          'type': scanModel.type,
          'isDfuMode': scanModel.isDfuMode,
        };

        final existingIndex = discoveredGateways.indexWhere((gateway) => gateway['gatewayMac'] == scanModel.gatewayMac);

        if (existingIndex >= 0) {
          discoveredGateways[existingIndex] = gatewayInfo;
        } else {
          AppLogger.i('Adding gateway to list: $gatewayInfo');
          discoveredGateways.add(gatewayInfo);
        }
      }
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (isScanning.value) {
        stopScan();
      }
    });
  }

  Future<void> _checkGatewayInitStatus() async {
    try {
      final gatewayMac = selectedGateway.value['gatewayMac'];
      final result = await repository.checkGatewayInitStatus(gatewayNetMac: gatewayMac);

      if (result['success'] == true) {
        AppLogger.i('Gateway successfully registered with TTLock cloud, gateway ID: ${result['gatewayId']}');

        // Reload the gateway list
        loadInitializedGateways();
      } else {
        AppLogger.w('Gateway not yet registered with TTLock cloud');
      }
    } catch (e) {
      AppLogger.e('Error checking gateway initialization status: $e');
    }
  }

  void stopScan() {
    TTGateway.stopScan();
    isScanning.value = false;
    AppLogger.i('Gateway scan stopped');
  }

  void connectToGateway(Map<String, dynamic> gateway) {
    if (isConnecting.value) return;

    selectedGateway.value = gateway;
    isConnecting.value = true;

    final String mac = gateway['gatewayMac'];
    AppLogger.i('Connecting to gateway: $mac');

    TTGateway.connect(mac, (status) {
      isConnecting.value = false;

      switch (status) {
        case TTGatewayConnectStatus.success:
          isConnected.value = true;
          connectedGatewayMac.value = mac;
          AppLogger.i('Successfully connected to gateway: $mac');

          // Configure IP before scanning for WiFi (important for both G2 and G3/G4)
          _configureIpAddress(mac);

          break;

        case TTGatewayConnectStatus.timeout:
          isConnected.value = false;
          connectedGatewayMac.value = "";
          AppLogger.e('Connection to gateway timed out: $mac');
          Get.snackbar(
            'Connection Failed',
            'Connection to gateway timed out. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
          );
          break;

        case TTGatewayConnectStatus.faile:
          isConnected.value = false;
          connectedGatewayMac.value = "";
          AppLogger.e('Failed to connect to gateway: $mac');
          Get.snackbar(
            'Connection Failed',
            'Failed to connect to gateway. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
          );
          break;
      }
    });
  }

  void _configureIpAddress(String mac) {
    isConfiguringIp.value = true;
    AppLogger.i('Configuring IP for gateway: $mac');

    // Use DHCP by default which is recommended for most networks
    Map<String, dynamic> ipParams = {
      'type': 1, // DHCP
    };

    // For static IP, use this configuration:
    // Map<String, dynamic> ipParams = {
    //   'type': 0, // Static IP
    //   'ipAddress': '192.168.1.100',
    //   'subnetMask': '255.255.255.0',
    //   'router': '192.168.1.1',
    //   'preferredDns': '8.8.8.8',
    //   'alternateDns': '8.8.4.4',
    // };

    TTGateway.configIp(ipParams, () {
      isConfiguringIp.value = false;
      AppLogger.i('IP configuration succeeded for gateway: $mac');

      // If G2 gateway, scan for WiFi networks after IP configuration
      if (selectedGateway.value['type'] == TTGatewayType.g2) {
        scanWifiNetworks();
      }
    }, (error, message) {
      isConfiguringIp.value = false;
      AppLogger.e('IP configuration failed: $message (Error code: $error)');

      // Continue even if IP config fails, as default might be okay
      if (selectedGateway.value['type'] == TTGatewayType.g2) {
        scanWifiNetworks();
      }
    });
  }

  void disconnectGateway() {
    if (!isConnected.value) return;

    final mac = connectedGatewayMac.value;
    if (mac.isEmpty) return;

    TTGateway.disconnect(mac, () {
      AppLogger.i('Disconnected from gateway: $mac');
      isConnected.value = false;
      connectedGatewayMac.value = "";
    });
  }

  void scanWifiNetworks() {
    if (!isConnected.value || isScanningWifi.value) return;

    isScanningWifi.value = true;
    discoveredWifiNetworks.clear();

    TTGateway.getNearbyWifi((finished, wifiList) {
      AppLogger.i('WiFi scan result - Finished: $finished, Networks: ${wifiList.length}');

      if (wifiList.isNotEmpty) {
        for (var wifi in wifiList) {
          final wifiInfo = {
            'name': wifi['wifi'],
            'rssi': wifi['rssi'],
          };

          final existingIndex = discoveredWifiNetworks.indexWhere((net) => net['name'] == wifi['wifi']);

          if (existingIndex >= 0) {
            discoveredWifiNetworks[existingIndex] = wifiInfo;
          } else {
            discoveredWifiNetworks.add(wifiInfo);
          }
        }

        // Sort by signal strength
        discoveredWifiNetworks.sort((a, b) => (b['rssi'] as int).compareTo(a['rssi'] as int));
      }

      if (finished) {
        isScanningWifi.value = false;
      }
    }, (error, message) {
      isScanningWifi.value = false;
      AppLogger.e('Error scanning WiFi networks: $message (Error code: $error)');

      Get.snackbar(
        'WiFi Scan Failed',
        'Failed to scan WiFi networks: $message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    });
  }

  void selectWifiNetwork(String name) {
    wifiNameController.text = name;
  }

  void _performGatewayInitialization(Map<String, dynamic> initParams) {
    // Log the initialization parameters (excluding password)
    final logParams = {...initParams};
    logParams.remove('ttlockLoginPassword');
    logParams.remove('wifiPassword');
    AppLogger.i('Gateway initialization parameters: $logParams');

    // Add debugging to see exact parameters being sent
    AppLogger.i('Raw initialization parameters: $initParams');

    try {
      TTGateway.init(initParams, (result) {
        isInitializing.value = false;
        AppLogger.i('Gateway initialization successful: $result');

        // _checkGatewayInitStatus();

        Get.snackbar(
          'Success',
          'Gateway has been successfully initialized',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }, (error, message) {
        isInitializing.value = false;
        AppLogger.e('Gateway initialization failed: $message (Error code: $error)');

        String errorMessage = 'Initialization error: $message';

        // Provide more helpful error messages
        if (error == TTGatewayError.notConnect || error == TTGatewayError.disconnect) {
          errorMessage = 'Gateway disconnected. Please repower the gateway and try again.';
        } else if (error == TTGatewayError.wrongWifi || error == TTGatewayError.wrongWifiPassword) {
          errorMessage = 'Invalid WiFi credentials. Please check and try again.';
        } else if (error == TTGatewayError.failConfigAccount) {
          errorMessage = 'Failed to configure account. Please verify your TTLock account credentials and user ID.';
        } else if (error == TTGatewayError.fail) {
          errorMessage = 'Parameter format incorrect. Please check gateway type and user ID format.';
        }

        Get.snackbar(
          'Initialization Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      });
    } catch (e) {
      isInitializing.value = false;
      AppLogger.e('Exception during gateway initialization: $e');
      Get.snackbar(
        'Initialization Error',
        'Unexpected error during gateway initialization',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void setNeedRefresh(bool value) {
    needRefreshOnBack.value = value;
  }
}
