import 'dart:async';

import 'package:flutter_getx_boilerplate/models/response/ttlock_response/ttlock_detail_response.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_response/ttlock_item_response.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttlock.dart';

import '../../models/response/error/error_response.dart';
import '../../shared/utils/logger.dart';
import '../base/base_controller.dart';

class LockDetailController extends BaseController<TTLockRepository> {
  TTLockInitializedItem? lockInfo;

  final batteryLevel = 0.obs;
  final remoteControlState = false.obs;

  final isRemoteActionInProgress = false.obs;
  final remoteAction = ''.obs;
  final remoteLockState = (-1).obs;

  final isRemoteUnlockSettingInProgress = false.obs;
  final hasRemoteUnlockFeature = false.obs;

  TTLockDetailResponse? lockDetail;
  String? lockData;

  LockDetailController(super.repository);

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is TTLockInitializedItem) {
      lockInfo = Get.arguments;
      lockData = lockInfo?.lockData;

      Future.delayed(const Duration(milliseconds: 300), () async {
        getLockOpenState();
        await getLockDetail();
        // await fetchLockDataFromAPI();
        getLockRemoteUnlockSwitchState();
      });
    }
  }

  // Future<void> fetchLockDataFromAPI() async {
  //   if (lockInfo?.lockId == null) {
  //     AppLogger.i('Cannot fetch lockData from API: Lock ID not available');
  //     return;
  //   }

  //   try {
  //     AppLogger.i('Fetching lockData from API for lock ID: ${lockInfo?.lockId}');

  //     isRemoteActionInProgress.value = true;
  //     remoteAction.value = 'setup';

  //     final lockId = lockInfo?.lockId ?? 0;
  //     final response = await repository.getEKey(lockId);
  //   } catch (e) {
  //     if (e is ErrorResponse) {
  //       AppLogger.e('LockData fetch failed with error: ${e.message}');
  //     } else {
  //       AppLogger.e('LockData fetch failed with exception: ${e.runtimeType} - $e');
  //     }
  //   } finally {
  //     isRemoteActionInProgress.value = false;
  //     remoteAction.value = '';
  //   }
  // }

  Future<void> getLockDetail() async {
    if (lockInfo?.lockId == null) {
      AppLogger.i('Cannot fetch lock detail: Lock ID not available');
      return;
    }

    try {
      isRemoteActionInProgress.value = true;
      remoteAction.value = 'setup';

      AppLogger.i('Fetching lock details for ID: ${lockInfo?.lockId}');

      final res = await repository.getLockDetail(lockInfo?.lockId ?? 0);
      lockDetail = res;

      batteryLevel.value = res.electricQuantity;
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
    if (lockInfo?.lockId == null) {
      AppLogger.i('Cannot query lock state: Lock ID not available');
      return;
    }

    final bool showIndicator = remoteAction.value.isEmpty && showLoadingIndicator;

    if (showIndicator) {
      isRemoteActionInProgress.value = true;
      remoteAction.value = 'query';
    }

    try {
      AppLogger.i('Querying lock state for ID: ${lockInfo?.lockId}');

      final response = await repository.queryLockOpenState(lockInfo?.lockId ?? 0);
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

    TTLock.getLockRemoteUnlockSwitchState(lockData ?? '', (isOn) {
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
    if (lockInfo?.lockId == null) {
      showError(
        'Unlock Error',
        'Cannot perform remote unlock: Lock ID not available',
      );
      return;
    }

    isRemoteActionInProgress.value = true;
    remoteAction.value = 'unlock';

    try {
      AppLogger.i('Starting remote unlock for lock ID: ${lockInfo?.lockId}');
      final response = await repository.remoteControlLock(
        lockId: lockInfo?.lockId ?? 0,
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
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot perform remote lock: Lock ID not available',
      );
      return;
    }

    isRemoteActionInProgress.value = true;
    remoteAction.value = 'lock';

    try {
      AppLogger.i('Starting remote lock for lock ID: ${lockInfo?.lockId}');
      final response = await repository.remoteControlLock(
        lockId: lockInfo?.lockId ?? 0,
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
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot delete lock: Lock ID not available',
      );
      return;
    }

    isRemoteActionInProgress.value = true;
    remoteAction.value = 'delete';

    try {
      final lockId = lockInfo?.lockId ?? 0;

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

    TTLock.resetLock(lockData ?? '', () {
      AppLogger.i('Lock reset successful before deletion');
      completer.complete();
    }, (errorCode, errorMsg) {
      AppLogger.e('Failed to reset lock before deletion: $errorCode - $errorMsg');
      completer.completeError(ErrorResponse(message: 'Failed to reset lock: $errorMsg'));
    });

    return completer.future;
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

    TTLock.setLockRemoteUnlockSwitchState(newState, lockData ?? '', (updatedLockData) {
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
}
