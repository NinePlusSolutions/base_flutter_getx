import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/services/camera_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_service.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/camera/camera_preview_widget.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/image/image_viewer_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

enum CheckinStatus {
  notCheckedIn,
  checkedIn,
  processing,
}

class CheckinController extends GetxController {
  final CameraService _cameraService = Get.find<CameraService>();
  final LocationService _locationService = Get.find<LocationService>();

  final checkinStatus = CheckinStatus.notCheckedIn.obs;
  final isLoading = false.obs;
  final notes = TextEditingController();

  // Current location data
  final currentPosition = Rx<Position?>(null);
  final currentAddress = ''.obs;

  // Simple list to store captured images with details
  final capturedImages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        currentPosition.value = position;
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        currentAddress.value = address;
      } else {
        Get.snackbar("Error", "Unable to get current location");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to get location: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performCheckin() async {
    await _performCheckinAction('checkin');
  }

  Future<void> performCheckout() async {
    await _performCheckinAction('checkout');
  }

  Future<void> _performCheckinAction(String type) async {
    try {
      isLoading.value = true;
      checkinStatus.value = CheckinStatus.processing;

      // Check camera permission
      final hasCameraPermission = await _cameraService.requestCameraPermission();
      if (!hasCameraPermission) {
        Get.snackbar("Permission Required", "Camera permission is required for $type");
        _resetCheckinStatus();
        return;
      }

      // Get current location
      await getCurrentLocation();
      if (currentPosition.value == null) {
        Get.snackbar("Location Error", "Failed to get current location");
        _resetCheckinStatus();
        return;
      }

      // Navigate to camera screen
      final imageBase64 = await Get.to<String>(
        () => _buildCameraScreen(type),
        fullscreenDialog: true,
      );

      if (imageBase64 == null) {
        _resetCheckinStatus();
        return;
      }

      // Save captured image locally
      final imageData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
        'latitude': currentPosition.value!.latitude,
        'longitude': currentPosition.value!.longitude,
        'address': currentAddress.value,
        'imageBase64': imageBase64,
        'timestamp': DateTime.now().toIso8601String(),
        'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
      };

      capturedImages.insert(0, imageData);

      // Save image to device gallery
      final savedToGallery = await _cameraService.saveImageToGallery(
        imageBase64,
        filename: '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (savedToGallery) {
        debugPrint('Image saved to gallery successfully');
      } else {
        debugPrint('Failed to save image to gallery');
      }

      // Update local state
      checkinStatus.value = type == 'checkin' ? CheckinStatus.checkedIn : CheckinStatus.notCheckedIn;

      // Clear notes
      notes.clear();

      Get.snackbar(
        "Success",
        "$type completed successfully${savedToGallery ? ' and saved to gallery' : ''}",
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to perform $type: $e");
      _resetCheckinStatus();
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildCameraScreen(String type) {
    return Scaffold(
      body: CameraPreviewWidget(
        locationText: currentAddress.value,
        gpsText: currentPosition.value != null
            ? '${currentPosition.value!.latitude.toStringAsFixed(6)}, ${currentPosition.value!.longitude.toStringAsFixed(6)}'
            : null,
        latitude: currentPosition.value?.latitude,
        longitude: currentPosition.value?.longitude,
        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
        onCapture: (imageBase64) async {
          Get.back(result: imageBase64);
        },
        onCancel: () {
          Get.back();
        },
      ),
    );
  }

  void _resetCheckinStatus() {
    // Check last action to determine status
    if (capturedImages.isNotEmpty) {
      final lastAction = capturedImages.first['type'];
      if (lastAction == 'checkin') {
        checkinStatus.value = CheckinStatus.checkedIn;
      } else {
        checkinStatus.value = CheckinStatus.notCheckedIn;
      }
    } else {
      checkinStatus.value = CheckinStatus.notCheckedIn;
    }
  }

  void viewImageFullScreen(Map<String, dynamic> imageData) {
    Get.to(
      () => ImageViewerWidget(
        imageBase64: imageData['imageBase64'],
        imageData: imageData,
      ),
      fullscreenDialog: true,
      transition: Transition.fadeIn,
    );
  }

  // Delete captured image
  void deleteImage(String imageId) {
    capturedImages.removeWhere((image) => image['id'] == imageId);
    Get.snackbar("Success", "Image deleted successfully");
  }

  bool get canCheckin => checkinStatus.value == CheckinStatus.notCheckedIn;
  bool get canCheckout => checkinStatus.value == CheckinStatus.checkedIn;
  bool get isProcessing => checkinStatus.value == CheckinStatus.processing;

  String get statusText {
    switch (checkinStatus.value) {
      case CheckinStatus.notCheckedIn:
        return 'Not Checked In';
      case CheckinStatus.checkedIn:
        return 'Checked In';
      case CheckinStatus.processing:
        return 'Processing...';
    }
  }

  String? get lastActionTime {
    if (capturedImages.isEmpty) return null;
    final timestamp = DateTime.parse(capturedImages.first['timestamp']);
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    notes.dispose();
    super.onClose();
  }
}
