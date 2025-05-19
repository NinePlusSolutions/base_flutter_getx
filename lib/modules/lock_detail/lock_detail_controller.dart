import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttlock.dart';

import '../../models/response/error/error_response.dart';
import '../../shared/utils/logger.dart';
import '../base/base_controller.dart';

enum LockConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class LockDetailController extends BaseController<TTLockRepository> {
  final Rx<Map<String, dynamic>> lockInfo = Rx<Map<String, dynamic>>({});

  final batteryLevel = 0.obs;
  final remoteControlState = false.obs;

  final isInitializing = false.obs;

  final isRemoteActionInProgress = false.obs;
  final remoteAction = ''.obs;
  final remoteLockState = (-1).obs;

  final isRemoteUnlockSettingInProgress = false.obs;
  final hasRemoteUnlockFeature = false.obs;

  String? eKey;

  String? lockData;
  String? lockMac;
  String? lockVersion;

  LockDetailController(super.repository);

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      lockInfo.value = Get.arguments;

      lockMac = lockInfo.value['lockMac'];
      lockVersion = lockInfo.value['lockVersion'];
      lockData = lockInfo.value['lockData'];
      final bool hasLockId = lockInfo.value['lockId'] != null;

      if (lockInfo.value['electricQuantity'] != null) {
        batteryLevel.value = lockInfo.value['electricQuantity'];
      }

      AppLogger.i(
        'Initializing lock controller: hasLockId=$hasLockId, hasGateway=${lockInfo.value['hasGateway']}',
      );

      if (hasLockId && lockInfo.value['hasGateway'] == true) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          getLockOpenState();
          getLockDetail();
          await fetchLockDataFromAPI();
          getLockRemoteUnlockSwitchState();
        });
      }
    }
  }

  Future<void> fetchLockDataFromAPI() async {
    if (lockInfo.value['lockId'] == null) {
      AppLogger.i('Cannot fetch lockData from API: Lock ID not available');
      return;
    }

    try {
      AppLogger.i('Fetching lockData from API for lock ID: ${lockInfo.value['lockId']}');

      isRemoteActionInProgress.value = true;
      remoteAction.value = 'setup';

      final lockId = lockInfo.value['lockId'];
      final response = await repository.getEKey(lockId);

      if (response.containsKey('lockData') && response['lockData'] != null) {
        lockData = response['lockData'];
        AppLogger.i('LockData fetched successfully from API: $lockData');
      } else {
        AppLogger.e('API response does not contain lockData');
      }
    } catch (e) {
      if (e is ErrorResponse) {
        AppLogger.e('LockData fetch failed with error: ${e.message}');
      } else {
        AppLogger.e('LockData fetch failed with exception: ${e.runtimeType} - $e');
      }
    } finally {
      isRemoteActionInProgress.value = false;
      remoteAction.value = '';
    }
  }

  Future<void> getLockDetail() async {
    if (lockInfo.value['lockId'] == null) {
      AppLogger.i('Cannot fetch lock detail: Lock ID not available');
      return;
    }

    try {
      isRemoteActionInProgress.value = true;
      remoteAction.value = 'setup';

      AppLogger.i('Fetching lock details for ID: ${lockInfo.value['lockId']}');

      final lockDetail = await repository.getLockDetail(lockInfo.value['lockId']);

      lockInfo.value = {
        ...lockInfo.value,
        'lockMac': lockDetail.lockMac,
        'lockVersion': lockDetail.hardwareRevision,
        'lockName': lockDetail.lockName,
        'lockAlias': lockDetail.lockAlias,
        'hasGateway': lockDetail.hasGateway,
        'electricQuantity': lockDetail.electricQuantity,
        'featureValue': lockDetail.featureValue,
        'isInited': true,
      };

      lockMac = lockDetail.lockMac;
      lockVersion = lockDetail.hardwareRevision;
      batteryLevel.value = lockDetail.electricQuantity;

      AppLogger.i('Lock detail fetched successfully. MAC: $lockMac, Version: $lockVersion');
    } catch (e) {
      String errorMessage = 'Failed to fetch lock details';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Lock details fetch failed with error: ${e.message}');
      } else {
        AppLogger.e('Lock details fetch failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Error',
        errorMessage,
      );
    } finally {
      isRemoteActionInProgress.value = false;
      remoteAction.value = '';
    }
  }

  Future<void> getLockOpenState({bool showLoadingIndicator = true}) async {
    if (lockInfo.value['lockId'] == null) {
      AppLogger.i('Cannot query lock state: Lock ID not available');
      return;
    }

    final bool showIndicator = remoteAction.value.isEmpty && showLoadingIndicator;

    if (showIndicator) {
      isRemoteActionInProgress.value = true;
      remoteAction.value = 'query';
    }

    try {
      AppLogger.i('Querying lock state for ID: ${lockInfo.value['lockId']}');

      final response = await repository.queryLockOpenState(lockInfo.value['lockId']);
      if (response.containsKey('state')) {
        final int state = response['state'];
        remoteLockState.value = state;

        AppLogger.i('Lock state query successful: state=$state');
      } else {
        AppLogger.e('Lock state query missing state field in response');
      }
    } catch (e) {
      String errorMessage = 'Failed to query lock state';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Lock state query failed with error: ${e.message}');
      } else {
        AppLogger.e('Lock state query failed with exception: ${e.runtimeType} - $e');
      }

      if (showIndicator) {
        showError(
          'Query Failed',
          errorMessage,
        );
      }
    } finally {
      if (showIndicator) {
        isRemoteActionInProgress.value = false;
        remoteAction.value = '';
      }
    }
  }

  Future<void> initializeLockWithAccount(String lockAlias) async {
    if (lockData == null) {
      showError(
        'Error',
        'No lock data available to initialize',
      );
      return;
    }

    isInitializing.value = true;
    AppLogger.i('Initializing lock with alias: $lockAlias');

    try {
      final response = await repository.initializeLock(
        lockData: lockData!,
        lockAlias: lockAlias,
      );

      AppLogger.i('Lock initialized successfully: ${response.lockId}, keyId: ${response.keyId}');

      lockInfo.value = {
        ...lockInfo.value,
        'isInited': true,
        'lockId': response.lockId,
        'lockAlias': lockAlias,
      };

      isInitializing.value = false;

      showSuccess(
        'Success',
        'Lock successfully initialized and added to your account',
      );
    } catch (e) {
      isInitializing.value = false;

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

  void getLockRemoteUnlockSwitchState() {
    if (lockData == null) {
      AppLogger.i('Cannot get remote unlock state: Lock not connected');
      showError(
        'Connection Error',
        'Please connect to the lock first',
      );
      return;
    }

    isRemoteUnlockSettingInProgress.value = true;
    AppLogger.i('Getting remote unlock switch state');

    TTLock.getLockRemoteUnlockSwitchState(lockData!, (isOn) {
      AppLogger.i('Remote unlock state retrieved: $isOn');
      remoteControlState.value = isOn;
      isRemoteUnlockSettingInProgress.value = false;
    }, (errorCode, errorMsg) {
      isRemoteUnlockSettingInProgress.value = false;
      AppLogger.e('Failed to get remote unlock state: $errorCode - $errorMsg');

      showError(
        'Remote Unlock Error',
        'Failed to check remote unlock state: $errorMsg',
      );
    });
  }

  Future<void> remoteUnlock() async {
    if (lockInfo.value['lockId'] == null) {
      showError(
        'Unlock Error',
        'Cannot perform remote unlock: Lock ID not available',
      );
      return;
    }

    isRemoteActionInProgress.value = true;
    remoteAction.value = 'unlock';

    try {
      AppLogger.i('Starting remote unlock for lock ID: ${lockInfo.value['lockId']}');
      final response = await repository.remoteControlLock(
        lockId: lockInfo.value['lockId'],
        controlAction: 'unlock',
      );

      if (response['errcode'] == 0) {
        remoteLockState.value = 1;

        AppLogger.i('Remote unlock successful');

        Future.delayed(const Duration(seconds: 5), () {
          getLockOpenState(showLoadingIndicator: false);
        });

        showSuccess(
          'Success',
          'Door unlocked remotely',
        );
      } else if (response['errcode'] == -4043) {
        AppLogger.e('Remote unlock failed: Remote unlock feature is not enabled');
      } else {
        final errorMsg = response['errmsg'] ?? 'Unknown error during remote unlock';
        AppLogger.e('Remote unlock API error: ${response['errcode']} - $errorMsg');
        throw ErrorResponse(message: errorMsg);
      }
    } finally {
      isRemoteActionInProgress.value = false;
      remoteAction.value = '';
    }
  }

  Future<void> remoteLock() async {
    if (lockInfo.value['lockId'] == null) {
      showError(
        'Error',
        'Cannot perform remote lock: Lock ID not available',
      );
      return;
    }

    isRemoteActionInProgress.value = true;
    remoteAction.value = 'lock';

    try {
      AppLogger.i('Starting remote lock for lock ID: ${lockInfo.value['lockId']}');
      final response = await repository.remoteControlLock(
        lockId: lockInfo.value['lockId'],
        controlAction: 'lock',
      );

      if (response['errcode'] == 0) {
        AppLogger.i('Remote lock successful');

        Future.delayed(const Duration(seconds: 5), () {
          getLockOpenState(showLoadingIndicator: false);
        });

        showSuccess(
          'Success',
          'Door locked remotely',
        );
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Unknown error during remote lock');
      }
    } catch (e) {
      String errorMessage = 'Failed to lock remotely';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }

      AppLogger.e('Remote lock failed: $e');

      showError(
        'Remote Lock Failed',
        errorMessage,
      );
    } finally {
      isRemoteActionInProgress.value = false;
    }
  }

  Future<void> deleteLock() async {
    if (lockInfo.value['lockId'] == null) {
      showError(
        'Error',
        'Cannot delete lock: Lock ID not available',
      );
      return;
    }

    isRemoteActionInProgress.value = true;
    remoteAction.value = 'delete';

    try {
      final lockId = lockInfo.value['lockId'];

      AppLogger.i('Initiating lock deletion for ID: $lockId');

      if (lockData != null) {
        await _resetLock();
      }

      final response = await repository.deleteLock(lockId);

      if (response['errcode'] == 0) {
        AppLogger.i('Lock deletion successful');

        showSuccess(
          'Success',
          'Lock has been deleted from your account successfully',
        );

        Future.delayed(const Duration(seconds: 2), () {
          Get.back(result: {'deleted': true});
        });
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Unknown error during lock deletion');
      }
    } catch (e) {
      String errorMessage = 'Failed to delete lock';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }

      AppLogger.e('Lock deletion failed: $e');

      showError(
        'Deletion Failed',
        errorMessage,
      );
    } finally {
      isRemoteActionInProgress.value = false;
      remoteAction.value = '';
    }
  }

  Future<void> _resetLock() async {
    if (lockData == null) {
      AppLogger.e('Cannot reset lock: No lockData available');
      throw ErrorResponse(message: 'Cannot reset lock before deletion: No lock data available');
    }

    AppLogger.i('Resetting lock before deletion');

    final completer = Completer<void>();

    TTLock.resetLock(lockData!, () {
      AppLogger.i('Lock reset successful before deletion');
      completer.complete();
    }, (errorCode, errorMsg) {
      AppLogger.e('Failed to reset lock before deletion: $errorCode - $errorMsg');
      completer.completeError(ErrorResponse(message: 'Failed to reset lock: $errorMsg'));
    });

    return completer.future;
  }

  void initLock() {
    final Map<String, String> lockParams = {
      'lockMac': lockMac!,
      'lockVersion': lockVersion!,
    };

    TTLock.initLock(lockParams, (lockDataResult) {
      AppLogger.i('Connected to lock successfully');
      lockData = lockDataResult;
      getLockPower(lockDataResult);
      getLockRemoteUnlockSwitchState();
      _showInitializationDialog();
    }, (errorCode, errorMsg) {
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

  void _showInitializationDialog() {
    final TextEditingController nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Initialize Lock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter a name for your lock:'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Lock Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
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
              initializeLockWithAccount(lockName);
            },
          ),
        ],
      ),
    );
  }

  void toggleRemoteUnlockSwitch() {
    if (lockData == null) {
      AppLogger.i('Cannot toggle remote unlock: Lock not connected');
      showError(
        'Connection Error',
        'Please connect to the lock first',
      );
      return;
    }

    isRemoteUnlockSettingInProgress.value = true;

    final bool newState = !remoteControlState.value;

    AppLogger.i('Setting remote unlock switch to: $newState');

    TTLock.setLockRemoteUnlockSwitchState(newState, lockData!, (updatedLockData) {
      remoteControlState.value = newState;
      isRemoteUnlockSettingInProgress.value = false;

      AppLogger.i('Remote unlock state updated successfully to: $newState');

      showSuccess(
        'Success',
        newState ? 'Remote unlock enabled successfully' : 'Remote unlock disabled successfully',
      );
    }, (errorCode, errorMsg) {
      isRemoteUnlockSettingInProgress.value = false;

      AppLogger.e('Failed to update remote unlock state: $errorCode - $errorMsg');

      String actionText = newState ? "enable" : "disable";
      showError(
        'Error',
        'Failed to $actionText remote unlock: $errorMsg',
      );
    });
  }

  void unlockByBluetooth(String lockData) {
    AppLogger.i('Sending unlock via Bluetooth');

    TTLock.controlLock(lockData, TTControlAction.unlock, (lockTime, electricQuantity, uniqueId) {
      batteryLevel.value = electricQuantity;
      AppLogger.i('Unlock successful. Battery: $electricQuantity%');

      showSuccess(
        'Success',
        'Door unlocked successfully',
      );
    }, (errorCode, errorMsg) {
      AppLogger.e('Unlock failed');

      showError(
        'Unlock Failed',
        errorMsg,
      );
    });
  }

  void lockByBluetooth(String lockData) {
    TTLock.controlLock(lockData, TTControlAction.lock, (lockTime, electricQuantity, uniqueId) {
      AppLogger.i('Lock successful. Battery: $electricQuantity%');

      showSuccess('Lock Success', 'Lock successfully');
    }, (errorCode, errorMsg) {
      AppLogger.e('Lock failed: $errorCode - $errorMsg');
      showError('Lock Failed', 'Failed to lock: $errorMsg');
    });
  }

  void getLockPower(String lockData) {
    TTLock.getLockPower(lockData, (electricQuantity) {
      batteryLevel.value = electricQuantity;
      AppLogger.i('Lock power level: $electricQuantity%');
    }, (errorCode, errorMsg) {
      AppLogger.e('Failed to get power');
    });
  }

  bool get isLockInitialized {
    return lockInfo.value['isInited'] == true || lockInfo.value['lockId'] != null;
  }
}
