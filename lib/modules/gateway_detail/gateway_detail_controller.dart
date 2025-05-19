import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_list/gateway_list_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:flutter_getx_boilerplate/shared/utils/logger.dart';
import 'package:get/get.dart';

import '../base/base_controller.dart';

class GatewayDetailController extends BaseController<TTLockRepository> {
  final RxBool isLoadingDetail = false.obs;
  final Rx<Map<String, dynamic>> gatewayDetail = Rx<Map<String, dynamic>>({});
  final int gatewayId;

  final TextEditingController renameController = TextEditingController();
  final RxBool isRenaming = false.obs;
  final RxBool isDeleting = false.obs;

  GatewayDetailController(super.repository, this.gatewayId);

  @override
  void onInit() {
    super.onInit();
    loadGatewayDetail();
  }

  @override
  void onClose() {
    renameController.dispose();
    super.onClose();
  }

  Future<void> loadGatewayDetail() async {
    if (isLoadingDetail.value) return;

    isLoadingDetail.value = true;
    gatewayDetail.value = {};

    try {
      AppLogger.i('Loading gateway details for ID: $gatewayId');

      final response = await repository.getGatewayDetail(gatewayId);

      gatewayDetail.value = response;

      renameController.text = response['gatewayName'] ?? '';

      AppLogger.i('Successfully loaded gateway details: ${gatewayDetail.value}');
    } catch (e) {
      String errorMessage = 'Failed to load gateway details';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }

      AppLogger.e('Failed to load gateway details: $e');

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> renameGateway() async {
    final newName = renameController.text.trim();

    if (newName.isEmpty) {
      Get.snackbar(
        'Error',
        'Gateway name cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    isRenaming.value = true;

    try {
      AppLogger.i('Renaming gateway ID: $gatewayId to: $newName');

      // Gọi API để đổi tên gateway
      final response = await repository.renameGateway(gatewayId, newName);

      if (response['errcode'] == 0) {
        // Cập nhật thông tin gateway trong local state
        gatewayDetail.update((val) {
          if (val != null) {
            val['gatewayName'] = newName;
          }
        });

        Get.back(); // Đóng dialog

        Get.snackbar(
          'Success',
          'Gateway renamed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Failed to rename gateway');
      }
    } catch (e) {
      String errorMessage = 'Failed to rename gateway';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }

      AppLogger.e('Failed to rename gateway: $e');

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isRenaming.value = false;
    }
  }

  Future<void> deleteGateway() async {
    isDeleting.value = true;

    try {
      AppLogger.i('Deleting gateway with ID: $gatewayId');

      // Gọi API để xóa gateway
      final response = await repository.deleteGateway(gatewayId);

      if (response['errcode'] == 0) {
        // Quay về màn hình trước
        Get.back();

        // Hiển thị thông báo thành công
        Get.snackbar(
          'Success',
          'Gateway has been deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );

        notifyGatewayDeleted();
      } else {
        throw ErrorResponse(message: response['errmsg'] ?? 'Failed to delete gateway');
      }
    } catch (e) {
      String errorMessage = 'Failed to delete gateway';
      if (e is ErrorResponse) {
        errorMessage = e.message;
      }

      AppLogger.e('Failed to delete gateway: $e');

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void showRenameDialog(BuildContext context) {
    renameController.text = gatewayDetail.value['gatewayName'] ?? '';

    Get.dialog(
      AlertDialog(
        title: const Text('Rename Gateway'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: renameController,
              decoration: const InputDecoration(
                labelText: 'Gateway Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              maxLength: 32,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => TextButton(
                onPressed: isRenaming.value ? null : () => renameGateway(),
                child: isRenaming.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              )),
        ],
      ),
    );
  }

  void notifyGatewayDeleted() {
  try {
    final gatewayListController = Get.find<GatewayListController>();
    gatewayListController.setNeedRefresh(true);
  } catch (e) {
    // Controller không tồn tại, không cần làm gì
  }
}
}
