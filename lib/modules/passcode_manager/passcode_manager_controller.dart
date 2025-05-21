import 'dart:async';

import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_keyboard_pwd/ttlock_keyboard_pwd_list_response.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_keyboard_pwd/ttlock_keyboard_pwd_model.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_response/ttlock_item_response.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:flutter_getx_boilerplate/shared/utils/logger.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttlock.dart';

class PasscodeManagerController extends BaseController<TTLockRepository> {
  PasscodeManagerController(super.repository);

  final RxList<TTLockKeyboardPwdModel> passcodes = <TTLockKeyboardPwdModel>[].obs;
  final isLoadingPasscodes = false.obs;
  final isDeletingPasscode = false.obs;
  final isChangingPasscode = false.obs;

  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalPasscodes = 0.obs;

  TTLockInitializedItem? lockInfo;
  String? lockData;

  Future<void> loadPasscodes({bool showLoading = true, int page = 1}) async {
    if (lockInfo?.lockId == null) {
      AppLogger.i('Cannot load passcodes: Lock ID not available');
      return;
    }

    if (showLoading) {
      isLoadingPasscodes.value = true;
    }

    try {
      AppLogger.i('Loading passcodes for lock ID: ${lockInfo?.lockId}, page: $page');

      final response = await repository.listKeyboardPwd(
        lockId: lockInfo!.lockId,
        pageNo: page,
        pageSize: 20,
      );

      if (page == 1) {
        passcodes.clear();
      }

      passcodes.addAll(response.list);
      currentPage.value = response.pageNo;
      totalPages.value = response.pages;
      totalPasscodes.value = response.total;

      AppLogger.i('Loaded ${response.list.length} passcodes, total: ${response.total}');
    } catch (e) {
      String errorMessage = 'Failed to load passcodes';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Load passcodes failed with error: ${e.message}');
      } else {
        AppLogger.e('Load passcodes failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Error',
        errorMessage,
      );
    } finally {
      isLoadingPasscodes.value = false;
    }
  }

  Future<void> deletePasscode(int keyboardPwdId) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot delete passcode: Lock ID not available',
      );
      return;
    }

    isDeletingPasscode.value = true;

    try {
      AppLogger.i('Deleting passcode ID: $keyboardPwdId from lock ID: ${lockInfo?.lockId}');

      // deleteType: 1 if connected via Bluetooth, 2 if via gateway/WiFi
      final deleteType = lockData != null ? 1 : 2;

      // Find the passcode first
      final passcode = passcodes.firstWhereOrNull((p) => p.keyboardPwdId == keyboardPwdId);

      if (deleteType == 1 && lockData != null && passcode != null) {
        // First, delete the passcode via Bluetooth if connected
        await _deletePasscodeViaBluetooth(passcode.keyboardPwd);
      }

      final response = await repository.deleteKeyboardPwd(
        lockId: lockInfo!.lockId,
        keyboardPwdId: keyboardPwdId,
        deleteType: deleteType,
      );

      if (response['errcode'] == 0) {
        AppLogger.i('Passcode deleted successfully');

        // Remove the passcode from the list
        passcodes.removeWhere((p) => p.keyboardPwdId == keyboardPwdId);

        showSuccess(
          'Success',
          'Passcode deleted successfully',
        );
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Failed to delete passcode');
      }
    } catch (e) {
      String errorMessage = 'Failed to delete passcode';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Delete passcode failed with error: ${e.message}');
      } else {
        AppLogger.e('Delete passcode failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Deletion Failed',
        errorMessage,
      );
    } finally {
      isDeletingPasscode.value = false;
    }
  }

  // Helper function to delete passcode via Bluetooth first
  Future<void> _deletePasscodeViaBluetooth(String passcode) async {
    if (lockData == null) {
      throw ErrorResponse(message: 'Cannot delete passcode via Bluetooth: No lock data available');
    }

    final completer = Completer<void>();

    TTLock.deletePasscode(
      passcode,
      lockData ?? '',
      () {
        AppLogger.i('Passcode deleted via Bluetooth successfully');
        completer.complete();
      },
      (errorCode, errorMsg) {
        AppLogger.e('Failed to delete passcode via Bluetooth: $errorCode - $errorMsg');
        completer.completeError(ErrorResponse(message: 'Failed to delete via Bluetooth: $errorMsg'));
      },
    );

    return completer.future;
  }

  // Change passcode name
  Future<void> changePasscodeName(int keyboardPwdId, String newName) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot change passcode name: Lock ID not available',
      );
      return;
    }

    isChangingPasscode.value = true;

    try {
      AppLogger.i('Changing passcode name for ID: $keyboardPwdId to "$newName"');

      final response = await repository.changeKeyboardPwd(
        lockId: lockInfo!.lockId,
        keyboardPwdId: keyboardPwdId,
        keyboardPwdName: newName,
      );

      if (response['errcode'] == 0) {
        AppLogger.i('Passcode name changed successfully');

        // Update the passcode in the list
        final index = passcodes.indexWhere((p) => p.keyboardPwdId == keyboardPwdId);
        if (index != -1) {
          final oldPasscode = passcodes[index];
          final updatedPasscode = TTLockKeyboardPwdModel.fromJson({
            ...oldPasscode.toJson(),
            'keyboardPwdName': newName,
          });
          passcodes[index] = updatedPasscode;
        }

        showSuccess(
          'Success',
          'Passcode name changed successfully',
        );
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Failed to change passcode name');
      }
    } catch (e) {
      String errorMessage = 'Failed to change passcode name';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Change passcode name failed with error: ${e.message}');
      } else {
        AppLogger.e('Change passcode name failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Update Failed',
        errorMessage,
      );
    } finally {
      isChangingPasscode.value = false;
    }
  }

  // Change passcode value (the actual code)
  Future<void> changePasscodeValue({
    required int keyboardPwdId,
    required String newPasscode,
    int? startDate,
    int? endDate,
  }) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot change passcode: Lock ID not available',
      );
      return;
    }

    isChangingPasscode.value = true;

    try {
      AppLogger.i('Changing passcode value for ID: $keyboardPwdId');

      // changeType: 1 if connected via Bluetooth, 2 if via gateway/WiFi
      final changeType = lockData != null ? 1 : 2;

      // Find the old passcode first
      final passcode = passcodes.firstWhereOrNull((p) => p.keyboardPwdId == keyboardPwdId);

      if (changeType == 1 && lockData != null && passcode != null) {
        // First, modify the passcode via Bluetooth if connected
        await _modifyPasscodeViaBluetooth(
            passcode.keyboardPwd, newPasscode, startDate ?? passcode.startDate, endDate ?? passcode.endDate);
      }

      final response = await repository.changeKeyboardPwd(
        lockId: lockInfo!.lockId,
        keyboardPwdId: keyboardPwdId,
        newKeyboardPwd: newPasscode,
        startDate: startDate,
        endDate: endDate,
        changeType: changeType,
      );

      if (response['errcode'] == 0) {
        AppLogger.i('Passcode value changed successfully');

        // Refresh the passcode list to get updated data
        await loadPasscodes();

        showSuccess(
          'Success',
          'Passcode changed successfully',
        );
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Failed to change passcode');
      }
    } catch (e) {
      String errorMessage = 'Failed to change passcode';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Change passcode failed with error: ${e.message}');
      } else {
        AppLogger.e('Change passcode failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Update Failed',
        errorMessage,
      );
    } finally {
      isChangingPasscode.value = false;
    }
  }

  // Helper function to modify passcode via Bluetooth first
  Future<void> _modifyPasscodeViaBluetooth(String oldPasscode, String newPasscode, int startDate, int endDate) async {
    if (lockData == null) {
      throw ErrorResponse(message: 'Cannot modify passcode via Bluetooth: No lock data available');
    }

    final completer = Completer<void>();

    TTLock.modifyPasscode(
      oldPasscode,
      newPasscode,
      startDate,
      endDate,
      lockData ?? '',
      () {
        AppLogger.i('Passcode modified via Bluetooth successfully');
        completer.complete();
      },
      (errorCode, errorMsg) {
        AppLogger.e('Failed to modify passcode via Bluetooth: $errorCode - $errorMsg');
        completer.completeError(ErrorResponse(message: 'Failed to modify via Bluetooth: $errorMsg'));
      },
    );

    return completer.future;
  }
}
