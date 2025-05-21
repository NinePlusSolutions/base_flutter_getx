import 'dart:async';

import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_response/ttlock_item_response.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:flutter_getx_boilerplate/shared/utils/logger.dart';
import 'package:get/get.dart';
import 'package:ttlock_flutter/ttlock.dart';

class CreatePasscodeController extends BaseController<TTLockRepository> {
  CreatePasscodeController(super.repository);

  final isCreatingPasscode = false.obs;

  TTLockInitializedItem? lockInfo;
  String? lockData;

  Future<Map<String, dynamic>?> getRandomPasscode({
    required int keyboardPwdType,
    String? keyboardPwdName,
    required int startDate,
    int? endDate,
  }) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot create passcode: Lock ID not available',
      );
      return null;
    }

    isCreatingPasscode.value = true;

    try {
      AppLogger.i('Getting random passcode for lock ID: ${lockInfo?.lockId}');

      final response = await repository.getRandomPasscode(
        lockId: lockInfo!.lockId,
        keyboardPwdType: keyboardPwdType,
        keyboardPwdName: keyboardPwdName,
        startDate: startDate,
        endDate: endDate,
      );

      AppLogger.i('Random passcode created successfully');

      return response;
    } catch (e) {
      String errorMessage = 'Failed to create random passcode';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Create random passcode failed with error: ${e.message}');
      } else {
        AppLogger.e('Create random passcode failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Creation Failed',
        errorMessage,
      );
      return null;
    } finally {
      isCreatingPasscode.value = false;
    }
  }

  // Add a custom passcode
  Future<Map<String, dynamic>?> addCustomPasscode({
    required String keyboardPwd,
    String? keyboardPwdName,
    int keyboardPwdType = 3, // Default to period type
    int? startDate,
    int? endDate,
  }) async {
    if (lockInfo?.lockId == null) {
      showError(
        'Error',
        'Cannot add custom passcode: Lock ID not available',
      );
      return null;
    }

    isCreatingPasscode.value = true;

    try {
      AppLogger.i('Adding custom passcode for lock ID: ${lockInfo?.lockId}');

      // addType: 1 if connected via Bluetooth, 2 if via gateway/WiFi
      final addType = lockData != null ? 1 : 2;

      if (addType == 1 && lockData != null) {
        // First, add the passcode via Bluetooth if connected
        await _addPasscodeViaBluetooth(keyboardPwd, startDate, endDate);
      }

      final response = await repository.addCustomPasscode(
        lockId: lockInfo!.lockId,
        keyboardPwd: keyboardPwd,
        keyboardPwdName: keyboardPwdName,
        keyboardPwdType: keyboardPwdType,
        startDate: startDate,
        endDate: endDate,
        addType: addType,
      );

      AppLogger.i('Custom passcode added successfully');

      showSuccess(
        'Success',
        'Passcode added successfully',
      );

      return response;
    } catch (e) {
      String errorMessage = 'Failed to add custom passcode';
      if (e is ErrorResponse) {
        errorMessage = e.message;
        AppLogger.e('Add custom passcode failed with error: ${e.message}');
      } else {
        AppLogger.e('Add custom passcode failed with exception: ${e.runtimeType} - $e');
      }

      showError(
        'Creation Failed',
        errorMessage,
      );
      return null;
    } finally {
      isCreatingPasscode.value = false;
    }
  }

  // Helper function to add passcode via Bluetooth first
  Future<void> _addPasscodeViaBluetooth(String passcode, int? startDate, int? endDate) async {
    if (lockData == null) {
      throw ErrorResponse(message: 'Cannot add passcode via Bluetooth: No lock data available');
    }

    final completer = Completer<void>();

    // Calculate start and end dates for TTLock SDK
    final now = DateTime.now().millisecondsSinceEpoch;
    final start = startDate ?? now;
    final end = endDate ?? (now + const Duration(days: 365).inMilliseconds);

    TTLock.createCustomPasscode(
      passcode,
      start,
      end,
      lockData ?? '',
      () {
        AppLogger.i('Passcode added via Bluetooth successfully');
        completer.complete();
      },
      (errorCode, errorMsg) {
        AppLogger.e('Failed to add passcode via Bluetooth: $errorCode - $errorMsg');
        completer.completeError(ErrorResponse(message: 'Failed to add via Bluetooth: $errorMsg'));
      },
    );

    return completer.future;
  }
}
