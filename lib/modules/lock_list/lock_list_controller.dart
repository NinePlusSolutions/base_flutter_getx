import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:flutter_getx_boilerplate/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttlock.dart';

import '../../../models/response/error/error_response.dart';
import '../../../models/response/ttlock_response/ttlock_item_response.dart';
import '../../../shared/utils/logger.dart';
import '../base/base_controller.dart';

class LockListController extends BaseController<TTLockRepository> {
  final RxBool isScanning = false.obs;
  final RxList<Map<String, dynamic>> discoveredLocks = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingInitializedLocks = false.obs;
  final RxList<TTLockItem> initializedLocks = <TTLockItem>[].obs;
  final RxBool hasLoadedInitializedLocks = false.obs;

  LockListController(super.repository);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future getData() async {
    loadInitializedLocks();
    return super.getData();
  }

  @override
  void onClose() {
    if (isScanning.value) {
      stopScan();
    }
    super.onClose();
  }

  void startScan() {
    if (isScanning.value) return;

    isScanning.value = true;
    discoveredLocks.clear();

    AppLogger.i('Starting lock scan');
    TTLock.startScanLock((scanModel) {
      AppLogger.i('Found lock: ${scanModel.lockName}, MAC: ${scanModel.lockMac}, Version: ${scanModel.lockVersion}');

      if (scanModel.lockMac.isNotEmpty) {
        final TTLockItem? initializedLock =
            initializedLocks.firstWhereOrNull((lock) => lock.lockMac == scanModel.lockMac);

        final lockInfo = {
          'lockMac': scanModel.lockMac,
          'lockName': scanModel.lockName.isNotEmpty ? scanModel.lockName : 'Unknown Lock',
          'electricQuantity': scanModel.electricQuantity,
          'isInited': scanModel.isInited,
          'lockVersion': scanModel.lockVersion,
          'lockSwitchState': scanModel.lockSwitchState.toString().split('.').last,
          if (initializedLock != null) ...{
            'lockId': initializedLock.lockId,
            'lockAlias': initializedLock.lockAlias,
            'onlineName': initializedLock.lockName,
            'onlineBattery': initializedLock.electricQuantity,
            'hasGateway': initializedLock.hasGateway == 1,
            'lockData': initializedLock.lockData,
            'groupId': initializedLock.groupId,
            'groupName': initializedLock.groupName,
          }
        };

        final existingIndex = discoveredLocks.indexWhere((lock) => lock['lockMac'] == scanModel.lockMac);

        if (existingIndex >= 0) {
          discoveredLocks[existingIndex] = lockInfo;
        } else {
          AppLogger.i('Adding lock to list: $lockInfo');
          discoveredLocks.add(lockInfo);
        }
      }
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (isScanning.value) {
        stopScan();
      }
    });
  }

  void stopScan() {
    TTLock.stopScanLock();
    isScanning.value = false;
    AppLogger.i('Scan stopped');
  }

  Future<void> loadInitializedLocks() async {
    if (!await repository.isAuthenticated()) {
      AppLogger.i('User not authenticated, skipping initialized locks loading');
      return;
    }

    if (isLoadingInitializedLocks.value) return;

    isLoadingInitializedLocks.value = true;
    AppLogger.i('Loading initialized locks from account');

    try {
      final response = await repository.getLockList(pageSize: 50);
      initializedLocks.value = response.list;
      hasLoadedInitializedLocks.value = true;

      AppLogger.i('Loaded ${initializedLocks.length} initialized locks from account');

      _updateDiscoveredLocksWithInitializedInfo();
    } catch (e) {
      String errorMessage = 'Failed to load initialized locks';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }

      AppLogger.e('Failed to load initialized locks: $e');

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoadingInitializedLocks.value = false;
    }
  }

  void _updateDiscoveredLocksWithInitializedInfo() {
    for (var i = 0; i < discoveredLocks.length; i++) {
      final discoveredLock = discoveredLocks[i];
      final String mac = discoveredLock['lockMac'];

      final TTLockItem? initializedLock = initializedLocks.firstWhereOrNull((lock) => lock.lockMac == mac);

      if (initializedLock != null) {
        discoveredLocks[i] = {
          ...discoveredLock,
          'isInited': true,
          'lockId': initializedLock.lockId,
          'lockAlias': initializedLock.lockAlias,
          'lockName': initializedLock.lockName,
          'onlineBattery': initializedLock.electricQuantity,
          'hasGateway': initializedLock.hasGateway == 1,
          'groupId': initializedLock.groupId,
          'groupName': initializedLock.groupName,
        };

        AppLogger.i('Updated discovered lock info for MAC: $mac with online data');
      }
    }
  }

  void showAllInitializedLocks() {
    if (initializedLocks.isEmpty) {
      loadInitializedLocks().then((_) {
        _addInitializedLocksToDiscoveredLocks();
      });
    } else {
      _addInitializedLocksToDiscoveredLocks();
    }
  }

  void _addInitializedLocksToDiscoveredLocks() {
    for (var initializedLock in initializedLocks) {
      final existingIndex = discoveredLocks.indexWhere((lock) => lock['lockMac'] == initializedLock.lockMac);

      if (existingIndex < 0) {
        final lockInfo = {
          'lockMac': initializedLock.lockMac,
          'lockName': initializedLock.lockName,
          'lockAlias': initializedLock.lockAlias,
          'electricQuantity': initializedLock.electricQuantity,
          'isInited': true,
          'lockId': initializedLock.lockId,
          'hasGateway': initializedLock.hasGateway == 1,
          'groupId': initializedLock.groupId,
          'groupName': initializedLock.groupName,
          'isOnlineOnly': true,
        };

        discoveredLocks.add(lockInfo);
        AppLogger.i('Added online-only lock to list: ${initializedLock.lockMac}');
      }
    }
  }

  void navigateToLockControl(Map<String, dynamic> lockInfo) {
    Get.toNamed(Routes.lock, arguments: lockInfo);
  }
}
