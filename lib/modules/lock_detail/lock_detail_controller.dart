import 'dart:async';
import 'dart:convert';

import 'package:flutter_getx_boilerplate/models/response/lock_response/lock_detail_response.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_response/ttlock_item_response.dart';
import 'package:flutter_getx_boilerplate/repositories/repositories.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:flutter_getx_boilerplate/shared/enum/enum.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttlock.dart';

import '../../models/request/request.dart';
import '../../models/response/error/error_response.dart';
import '../../shared/utils/logger.dart';
import '../base/base_controller.dart';

class LockDetailController extends BaseController<LockRepository> {
  final TTLockRepository lockRepository = Get.find();
  final GatewayRepository gatewayRepository = Get.find();
  final EkeyRepository ekeyRepository = Get.find();
  TTLockInitializedItem? lockInfo;

  final batteryLevel = 0.obs;
  final remoteControlState = false.obs;

  final isRemoteActionInProgress = false.obs;
  final remoteAction = ''.obs;
  final remoteLockState = (-1).obs;

  final isRemoteUnlockSettingInProgress = false.obs;
  final hasRemoteUnlockFeature = false.obs;

  final isBluetoothActionInProgress = false.obs;

  final isRenamingLock = false.obs;

  final isPassageModeEnabled = false.obs;
  final isAdminPasscodeUpdateInProgress = false.obs;
  final isPassageModeUpdateInProgress = false.obs;
  final isPassageModeConfigLoading = false.obs;
  final passageModeConfig = Rxn<Map<String, dynamic>>();

  final selectedControlType = 'remote'.obs;

  final isAutoLockUpdateInProgress = false.obs;
  final autoLockTime = RxnInt(null);

  LockDetailResponse? lockDetail;
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

  Future<void> fetchLockDataFromAPI() async {
    if (lockInfo?.lockId == null) {
      AppLogger.i('Cannot fetch lockData from API: Lock ID not available');
      return;
    }

    try {
      AppLogger.i('Fetching lockData from API for lock ID: ${lockInfo?.lockId}');

      isRemoteActionInProgress.value = true;
      remoteAction.value = 'setup';

      final lockId = lockInfo?.lockId ?? 0;
      final request = LockBaseRequest(
        lockId: lockId,
        date: DateTime.now().millisecondsSinceEpoch,
      );
      final response = await ekeyRepository.getEKey(request: request);
      lockData = response.lockData;
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
    if (lockInfo?.lockId == null) {
      AppLogger.i('Cannot fetch lock detail: Lock ID not available');
      return;
    }

    try {
      isRemoteActionInProgress.value = true;
      remoteAction.value = 'setup';

      AppLogger.i('Fetching lock details for ID: ${lockInfo?.lockId}');
      final request = LockBaseRequest(
        lockId: lockInfo?.lockId,
        date: DateTime.now().millisecondsSinceEpoch,
      );

      final res = await repository.getLockDetail(request: request);
      lockDetail = res;
      autoLockTime.value = res.autoLockTime;
      batteryLevel.value = res.electricQuantity ?? 0;
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

  Future<void> setAutoLockTime(int seconds) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot set auto lock time: Lock ID not available',
      );
      return;
    }

    isAutoLockUpdateInProgress.value = true;

    try {
      AppLogger.i('Setting auto lock time for lock ID: ${lockInfo?.lockId} to $seconds seconds');

      final request = AutoLockTimeRequest(
        lockId: lockInfo?.lockId,
        seconds: seconds,
        type: 2,
        date: DateTime.now().millisecondsSinceEpoch,
      );

      final response = await repository.setAutoLockTime(
        request: request,
      );

      if (response.isSuccess) {
        AppLogger.i('Auto lock time set successfully to $seconds seconds');

        showSuccess(
          'Success',
          seconds > 0 ? 'Auto lock time set to $seconds ${seconds == 1 ? 'second' : 'seconds'}' : 'Auto lock disabled',
        );
      } else {
        throw ErrorResponse(message: response.errmsg);
      }
    } catch (e) {
      String errorMessage = 'Failed to set auto lock time';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Set auto lock time failed with error: ${e.message}');
      } else {
        AppLogger.e('Set auto lock time failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Configuration Failed',
        errorMessage,
      );
    } finally {
      isAutoLockUpdateInProgress.value = false;
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
      final request = LockBaseRequest(
        lockId: lockInfo?.lockId,
        date: DateTime.now().millisecondsSinceEpoch,
      );
      final response = await gatewayRepository.queryLockOpenState(request: request);
      remoteLockState.value = response.state?.value ?? 2;
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
      final request = LockBaseRequest(
        lockId: lockInfo?.lockId,
        date: DateTime.now().millisecondsSinceEpoch,
      );
      final response = await gatewayRepository.remoteControlLock(
        request: request,
        controlAction: 'unlock',
      );

      if (response.errcode == 0) {
        remoteLockState.value = 1;

        AppLogger.i('Remote unlock successful');

        Future.delayed(const Duration(seconds: 5), () {
          getLockOpenState(showLoadingIndicator: false);
        });

        showSuccess(
          'Success',
          'Door unlocked remotely',
        );
      } else if (response.errcode == -4043) {
        AppLogger.e('Remote unlock failed: Remote unlock feature is not enabled');
      } else {
        final errorMsg = response.errmsg;
        AppLogger.e('Remote unlock API error: ${response.errcode} - $errorMsg');
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
      final request = LockBaseRequest(
        lockId: lockInfo?.lockId,
        date: DateTime.now().millisecondsSinceEpoch,
      );
      final response = await gatewayRepository.remoteControlLock(
        request: request,
        controlAction: 'lock',
      );

      if (response.errcode == 0) {
        AppLogger.i('Remote lock successful');

        Future.delayed(const Duration(seconds: 5), () {
          getLockOpenState(showLoadingIndicator: false);
        });

        showSuccess(
          'Success',
          'Door locked remotely',
        );
      } else {
        throw ErrorResponse(message: response.errmsg);
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

  Future<void> renameLock(String newName) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot rename lock: Lock ID not available',
      );
      return;
    }

    if (newName.trim().isEmpty) {
      showError(
        'Invalid Name',
        'Lock name cannot be empty',
      );
      return;
    }

    isRenamingLock.value = true;

    try {
      AppLogger.i('Renaming lock ID: ${lockInfo?.lockId} to "$newName"');
      final request = RenameLockRequest(
        lockId: lockInfo?.lockId,
        lockAlias: newName.trim(),
        date: DateTime.now().millisecondsSinceEpoch,
      );

      final response = await repository.renameLock(
        request: request,
      );

      if (response.isSuccess) {
        if (lockInfo != null) {
          lockInfo = lockInfo!.copyWith(lockAlias: newName.trim());
          update();
        }

        await getLockDetail();

        AppLogger.i('Lock renamed successfully to "$newName"');

        showSuccess(
          'Success',
          'Lock renamed successfully',
        );
      } else {
        throw ErrorResponse(message: response.errmsg);
      }
    } catch (e) {
      String errorMessage = 'Failed to rename lock';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Lock rename failed with error: ${e.message}');
      } else {
        AppLogger.e('Lock rename failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Rename Failed',
        errorMessage,
      );
    } finally {
      isRenamingLock.value = false;
    }
  }

  Future<void> getPassageModeConfiguration() async {
    if (lockInfo?.lockId == null) {
      AppLogger.i('Cannot get passage mode config: Lock ID not available');
      return;
    }

    isPassageModeConfigLoading.value = true;

    try {
      AppLogger.i('Fetching passage mode configuration for lock ID: ${lockInfo?.lockId}');
      final response = await lockRepository.getPassageModeConfiguration(lockId: lockInfo?.lockId ?? 0);

      passageModeConfig.value = response;
      isPassageModeEnabled.value = response['passageMode'] == 1;

      AppLogger.i('Passage mode configuration fetched successfully');
    } catch (e) {
      String errorMessage = 'Failed to get passage mode configuration';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Passage mode config fetch failed with error: ${e.message}');
      } else {
        AppLogger.e('Passage mode config fetch failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Configuration Error',
        errorMessage,
      );
    } finally {
      isPassageModeConfigLoading.value = false;
    }
  }

  Future<void> updateAdminPasscode(String newPasscode) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot update admin passcode: Lock ID not available',
      );
      return;
    }

    // Check if passcode is valid (typically 4-9 digits)
    if (!RegExp(r'^\d{4,9}$').hasMatch(newPasscode)) {
      showError(
        'Invalid Passcode',
        'Admin passcode must be 4-9 digits',
      );
      return;
    }

    isAdminPasscodeUpdateInProgress.value = true;

    try {
      AppLogger.i('Updating admin passcode for lock ID: ${lockInfo?.lockId}');

      // First step: If we have a direct Bluetooth connection to the lock,
      // update passcode via SDK first
      if (lockData != null) {
        await _updateAdminPasscodeViaBluetooth(newPasscode);
      }

      // Second step: Update on cloud via API
      // changeType: 1 - via Bluetooth, 2 - via gateway/WiFi
      final changeType = (lockData != null) ? 1 : 2;

      final response = await lockRepository.changeAdminPasscode(
        lockId: lockInfo?.lockId ?? 0,
        password: newPasscode,
        changeType: changeType,
      );

      if (response['errcode'] == 0) {
        AppLogger.i('Admin passcode updated successfully');
        showSuccess(
          'Success',
          'Admin passcode updated successfully',
        );
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Failed to update admin passcode');
      }
    } catch (e) {
      String errorMessage = 'Failed to update admin passcode';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Admin passcode update failed with error: ${e.message}');
      } else {
        AppLogger.e('Admin passcode update failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Update Failed',
        errorMessage,
      );
    } finally {
      isAdminPasscodeUpdateInProgress.value = false;
    }
  }

  Future<void> _updateAdminPasscodeViaBluetooth(String newPasscode) async {
    if (lockData == null) {
      throw ErrorResponse(message: 'Cannot update admin passcode via Bluetooth: No lock data available');
    }

    final completer = Completer<void>();

    TTLock.modifyAdminPasscode(newPasscode, lockData ?? '', () {
      AppLogger.i('Admin passcode updated via Bluetooth successfully');
      completer.complete();
    }, (errorCode, errorMsg) {
      AppLogger.e('Failed to update admin passcode via Bluetooth: $errorCode - $errorMsg');
      completer.completeError(ErrorResponse(message: 'Failed to update via Bluetooth: $errorMsg'));
    });

    return completer.future;
  }

  Future<void> configurePassageMode({
    required bool enable,
    required List<Map<String, dynamic>> cyclicConfig,
    bool autoUnlock = false,
  }) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot configure passage mode: Lock ID not available',
      );
      return;
    }

    isPassageModeUpdateInProgress.value = true;

    try {
      AppLogger.i('Configuring passage mode for lock ID: ${lockInfo?.lockId}');

      // Convert cyclic config to JSON string
      final cyclicConfigJson = jsonEncode(cyclicConfig);

      // First step: If we have a direct Bluetooth connection to the lock,
      // configure via SDK first for each passage mode entry
      if (lockData != null && enable) {
        for (final config in cyclicConfig) {
          await _configurePassageModeViaBluetooth(config);
        }

        // If disabling passage mode, clear all passage modes
        if (!enable) {
          await _clearAllPassageModesViaBluetooth();
        }
      }

      // Second step: Configure on cloud via API
      // type: 1 - via Bluetooth, 2 - via gateway/WiFi
      final type = (lockData != null) ? 1 : 2;

      final response = await lockRepository.configurePassageMode(
        lockId: lockInfo?.lockId ?? 0,
        passageMode: enable ? 1 : 2,
        cyclicConfig: cyclicConfigJson,
        type: type,
        autoUnlock: autoUnlock ? 1 : 2,
      );

      if (response['errcode'] == 0) {
        isPassageModeEnabled.value = enable;
        AppLogger.i('Passage mode configured successfully');

        // Refresh passage mode configuration
        await getPassageModeConfiguration();

        showSuccess(
          'Success',
          enable ? 'Passage mode enabled successfully' : 'Passage mode disabled successfully',
        );
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Failed to configure passage mode');
      }
    } catch (e) {
      String errorMessage = 'Failed to configure passage mode';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Passage mode configuration failed with error: ${e.message}');
      } else {
        AppLogger.e('Passage mode configuration failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Configuration Failed',
        errorMessage,
      );
    } finally {
      isPassageModeUpdateInProgress.value = false;
    }
  }

  Future<void> _configurePassageModeViaBluetooth(Map<String, dynamic> config) async {
    if (lockData == null) {
      throw ErrorResponse(message: 'Cannot configure passage mode via Bluetooth: No lock data available');
    }

    final completer = Completer<void>();

    // Convert from API format to SDK format
    final isAllDay = config['isAllDay'] == 1;
    final startTime = config['startTime'] as int;
    final endTime = config['endTime'] as int;
    final weekDays = List<int>.from(config['weekDays']);

    TTLock.addPassageMode(
      TTPassageModeType.weekly,
      weekDays,
      null, // monthly is null when using weekly
      startTime,
      endTime,
      lockData ?? '',
      () {
        AppLogger.i('Passage mode configured via Bluetooth successfully');
        completer.complete();
      },
      (errorCode, errorMsg) {
        AppLogger.e('Failed to configure passage mode via Bluetooth: $errorCode - $errorMsg');
        completer.completeError(ErrorResponse(message: 'Failed to configure via Bluetooth: $errorMsg'));
      },
    );

    return completer.future;
  }

  Future<void> _clearAllPassageModesViaBluetooth() async {
    if (lockData == null) {
      throw ErrorResponse(message: 'Cannot clear passage modes via Bluetooth: No lock data available');
    }

    final completer = Completer<void>();

    TTLock.clearAllPassageModes(
      lockData ?? '',
      () {
        AppLogger.i('All passage modes cleared via Bluetooth successfully');
        completer.complete();
      },
      (errorCode, errorMsg) {
        AppLogger.e('Failed to clear passage modes via Bluetooth: $errorCode - $errorMsg');
        completer.completeError(ErrorResponse(message: 'Failed to clear via Bluetooth: $errorMsg'));
      },
    );

    return completer.future;
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

      final response = await lockRepository.deleteLock(lockId);

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

  void setControlType(String type) {
    selectedControlType.value = type;

    // If switching to Bluetooth mode and we don't have lockData,
    // try to get the eKey data from API
    if (type == 'bluetooth' && lockData == null && lockInfo?.lockId != null) {
      fetchLockDataFromAPI();
    }
  }

  void unlockByBluetooth(String lockData) {
    if (isBluetoothActionInProgress.value) {
      return;
    }
    AppLogger.i('Sending unlock via Bluetooth');
    isBluetoothActionInProgress.value = true;

    TTLock.controlLock(lockData, TTControlAction.unlock, (lockTime, electricQuantity, uniqueId) {
      AppLogger.i('Unlock successful. Battery: $electricQuantity%');
      isBluetoothActionInProgress.value = false;
      showSuccess(
        'Success',
        'Door unlocked successfully',
      );
    }, (errorCode, errorMsg) {
      AppLogger.e('Unlock failed');
      isBluetoothActionInProgress.value = false;

      showError(
        'Unlock Failed',
        errorMsg,
      );
    });
  }

  void lockByBluetooth(String lockData) {
    if (isBluetoothActionInProgress.value) {
      return;
    }

    AppLogger.i('Sending lock via Bluetooth');

    isBluetoothActionInProgress.value = true;
    TTLock.controlLock(lockData, TTControlAction.lock, (lockTime, electricQuantity, uniqueId) {
      AppLogger.i('Lock successful. Battery: $electricQuantity%');
      isBluetoothActionInProgress.value = false;
      showSuccess('Lock Success', 'Lock successfully');
    }, (errorCode, errorMsg) {
      AppLogger.e('Lock failed: $errorCode - $errorMsg');
      isBluetoothActionInProgress.value = false;
      showError('Lock Failed', 'Failed to lock: $errorMsg');
    });
  }
}
