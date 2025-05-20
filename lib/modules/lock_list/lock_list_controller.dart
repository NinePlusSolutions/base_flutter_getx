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
  final RxList<TTLockInitializedItem> initializedLocks = <TTLockInitializedItem>[].obs;
  final RxList<TTLockScanModel> scannedLocks = <TTLockScanModel>[].obs;

  final isScanning = false.obs;
  final isLoadingInitializedLocks = false.obs;
  final isInitializingLock = false.obs;

  final currentTab = 0.obs;

  LockListController(super.repository);

  @override
  void onInit() {
    super.onInit();
    loadInitializedLocks();
  }

  Future<void> loadInitializedLocks() async {
    if (isLoadingInitializedLocks.value) return;
    isLoadingInitializedLocks.value = true;
    initializedLocks.clear();

    try {
      final isAuthenticated = await repository.isAuthenticated();
      if (!isAuthenticated) {
        AppLogger.e('User not authenticated');
        isLoadingInitializedLocks.value = false;
        return;
      }

      final response = await repository.getLockList(pageSize: 50);
      initializedLocks.value = response.list;

      AppLogger.i('Loaded ${initializedLocks.length} initialized locks from account');

      _removeDuplicateScannedLocks();
    } catch (e) {
      String errorMessage = 'Failed to load initialized locks';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }
      AppLogger.e('Error loading initialized locks: $e');
      showError('Error', errorMessage);
    } finally {
      isLoadingInitializedLocks.value = false;
    }
  }

  Future<void> _intitLockWithAccount(String lockData, String lockAlias) async {
    setLoading(true);

    try {
      AppLogger.i('Initializing lock with alias: $lockAlias');

      final response = await repository.initializeLock(
        lockData: lockData,
        lockAlias: lockAlias,
      );

      setLoading(false);
      isInitializingLock.value = false;

      AppLogger.i('Lock initialized successfully: ${response.lockId}, keyId: ${response.keyId}');

      showSuccess(
        'Success',
        'Lock successfully initialized and added to your account',
      );

      loadInitializedLocks();

      currentTab.value = 0;
    } catch (e) {
      setLoading(false);
      isInitializingLock.value = false;

      String errorMessage = 'Failed to initialize lock';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }

      AppLogger.e('Lock initialization failed: $e');

      showError(
        'Initialization Failed',
        errorMessage,
      );
    }
  }

  void startScan() {
    if (isScanning.value) return;

    isScanning.value = true;
    scannedLocks.clear();
    currentTab.value = 1;

    AppLogger.i('Started scanning for locks');

    TTLock.startScanLock((scanModel) {
      if (!isScanning.value) return;

      final isAlreadyInitialized = initializedLocks.any((lock) => lock.lockMac == scanModel.lockMac);

      if (!isAlreadyInitialized) {
        final existingIndex = scannedLocks.indexWhere((lock) => lock.lockMac == scanModel.lockMac);

        if (existingIndex >= 0) {
          scannedLocks[existingIndex] = scanModel;
        } else {
          scannedLocks.add(scanModel);
        }

        AppLogger.i('Found lock: ${scanModel.lockMac}, ${scanModel.lockName}, Added to scan list');
      } else {
        AppLogger.i('Found lock: ${scanModel.lockMac}, ${scanModel.lockName}, Skipped (already initialized)');
      }
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (isScanning.value) {
        stopScan();
      }
    });
  }

  void stopScan() {
    if (!isScanning.value) return;
    TTLock.stopScanLock();
    isScanning.value = false;
    AppLogger.i('Scan stopped');
  }

  void _removeDuplicateScannedLocks() {
    if (scannedLocks.isEmpty) return;

    List<TTLockScanModel> duplicates = [];

    for (var scanLock in scannedLocks) {
      final isInitialized = initializedLocks.any((lock) => lock.lockMac == scanLock.lockMac);
      if (isInitialized) {
        duplicates.add(scanLock);
      }
    }

    scannedLocks.removeWhere((lock) => duplicates.contains(lock));

    if (duplicates.isNotEmpty) {
      AppLogger.i('Removed ${duplicates.length} duplicated locks from scan list');
    }
  }

  void switchTab(int tabIndex) {
    if (currentTab.value == tabIndex) return;

    currentTab.value = tabIndex;
    if (tabIndex == 0 && isScanning.value) {
      stopScan();
    }
  }

  void onInitializedLockTap(TTLockInitializedItem lock) {
    stopScan();
    Get.toNamed(Routes.lock, arguments: lock);
  }

  void onScannedLockTap(TTLockScanModel lock) {
    showInitializeLockDialog(lock);
  }

  void navigateToLockControl(dynamic lockInfo) {
    stopScan();

    Map<String, dynamic> lockData;
    if (lockInfo is TTLockInitializedItem) {
      lockData = {
        'lockId': lockInfo.lockId,
        'lockName': lockInfo.lockName,
        'lockAlias': lockInfo.lockAlias,
        'lockMac': lockInfo.lockMac,
        'electricQuantity': lockInfo.electricQuantity,
        'featureValue': lockInfo.featureValue,
        'hasGateway': lockInfo.hasGateway,
        'lockData': lockInfo.lockData,
        'groupId': lockInfo.groupId,
        'groupName': lockInfo.groupName,
        'date': lockInfo.date,
      };
    } else if (lockInfo is TTLockScanModel) {
      lockData = {
        'lockName': lockInfo.lockName,
        'lockMac': lockInfo.lockMac,
        'isInited': lockInfo.isInited,
        'isAllowUnlock': lockInfo.isAllowUnlock,
        'electricQuantity': lockInfo.electricQuantity,
        'lockVersion': lockInfo.lockVersion,
        'lockSwitchState': lockInfo.lockSwitchState,
        'rssi': lockInfo.rssi,
        'oneMeterRssi': lockInfo.oneMeterRssi,
        'timestamp': lockInfo.timestamp,
      };
    } else {
      lockData = lockInfo;
    }

    Get.toNamed(Routes.lock, arguments: lockData)?.then((result) {
      if (result != null && result is Map && result['deleted'] == true) {
        loadInitializedLocks();
      }
    });
  }

  void showInitializeLockDialog(TTLockScanModel lock) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = lock.lockName.isNotEmpty ? lock.lockName : 'My Smart Lock';

    Get.dialog(
      AlertDialog(
        title: const Text('Initialize Lock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You are about to initialize this lock with your account. Please enter a name for your lock:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Lock Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'After initialization, the lock will be added to your account and can be managed remotely.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('Initialize'),
            onPressed: () {
              final String lockName = nameController.text.trim();
              if (lockName.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Lock name cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();
              _initializeLock(lock, lockName);
            },
          ),
        ],
      ),
    );
  }

  void _initializeLock(TTLockScanModel lock, String lockAlias) {
    if (isInitializingLock.value) return;

    final Map<String, dynamic> lockParams = {
      'lockMac': lock.lockMac,
      'lockVersion': lock.lockVersion,
    };

    isInitializingLock.value = true;

    AppLogger.i('Connecting to lock: ${lock.lockMac}');
    setLoading(true);

    TTLock.initLock(lockParams, (lockData) {
      setLoading(false);
      AppLogger.i('Connected to lock successfully, got lockData');

      _intitLockWithAccount(lockData, lockAlias);
    }, (errorCode, errorMsg) {
      setLoading(false);
      isInitializingLock.value = false;

      AppLogger.e('Lock connection failed: $errorCode - $errorMsg');
      if (errorMsg.toLowerCase().contains('none setting mode')) {
        showError(
          'Connection Failed',
          'This lock appears to be already initialized. Please use the associated account.',
        );
      } else {
        showError(
          'Connection Failed',
          errorMsg,
        );
      }
    });
  }

  @override
  void onClose() {
    if (isScanning.value) {
      stopScan();
    }
    super.onClose();
  }
}
