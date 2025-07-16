import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/services/camera_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_tracking_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/connectivity_service.dart';
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
  late final LocationTrackingService _trackingService;
  late final ConnectivityService _connectivityService;

  final checkinStatus = CheckinStatus.notCheckedIn.obs;
  final isLoading = false.obs;
  final notes = TextEditingController();

  // Current location data
  final currentPosition = Rx<Position?>(null);
  final currentAddress = ''.obs;

  // Location tracking data
  final isTrackingEnabled = false.obs;
  final trackingHistory = <LocationTrackingData>[].obs;
  final currentTrackingData = Rx<LocationTrackingData?>(null);

  // Connectivity state
  final isOnline = true.obs;
  final connectionType = ''.obs;

  // Simple list to store captured images with details
  final capturedImages = <Map<String, dynamic>>[].obs;

  // Stream subscriptions
  StreamSubscription<LocationTrackingData>? _trackingSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _trackingUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _setupListeners();
    getCurrentLocation();
  }

  /// Initialize tracking and connectivity services
  void _initializeServices() {
    try {
      _connectivityService = Get.find<ConnectivityService>();
    } catch (e) {
      _connectivityService = Get.put(ConnectivityService());
    }

    try {
      _trackingService = Get.find<LocationTrackingService>();
    } catch (e) {
      _trackingService = Get.put(LocationTrackingService());
    }
  }

  /// Setup listeners for tracking and connectivity
  void _setupListeners() {
    // Listen to tracking data
    _trackingSubscription = _trackingService.trackingStream.listen(
      (LocationTrackingData data) {
        currentTrackingData.value = data;
        currentPosition.value = data.position;
        currentAddress.value = data.address;

        debugPrint('Location tracking update: ${data.position.latitude}, ${data.position.longitude}');
      },
      onError: (error) {
        debugPrint('Tracking stream error: $error');
      },
    );

    // Listen to tracking state
    ever(_trackingService.isTracking, (bool isTracking) {
      isTrackingEnabled.value = isTracking;
      trackingHistory.assignAll(_trackingService.trackingHistory);

      // Start/stop timer for tracking duration updates
      if (isTracking) {
        _startTrackingUpdateTimer();
      } else {
        _stopTrackingUpdateTimer();
      }
    });

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (bool connected) {
        isOnline.value = connected;
        connectionType.value = _connectivityService.connectionTypeText;

        if (connected && isTrackingEnabled.value) {
          Get.snackbar(
            'Connection Restored',
            'Location tracking resumed',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        } else if (!connected && isTrackingEnabled.value) {
          Get.snackbar(
            'Connection Lost',
            'Location tracking continues offline',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      },
    );

    // Initial connectivity state
    isOnline.value = _connectivityService.isConnected.value;
    connectionType.value = _connectivityService.connectionTypeText;
  }

  Future<void> getCurrentLocation() async {
    // Use tracking data if available
    if (isTrackingEnabled.value && currentTrackingData.value != null) {
      currentPosition.value = currentTrackingData.value!.position;
      currentAddress.value = currentTrackingData.value!.address;
      return;
    }

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

  /// Start location tracking (internal - auto start after checkin only)
  Future<bool> _startLocationTracking() async {
    try {
      final success = await _trackingService.startTracking();
      return success;
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    try {
      await _trackingService.stopTracking();
    } catch (e) {
      debugPrint('Error stopping tracking: $e');
    }
  }

  /// Start timer for tracking duration updates (more frequent for realtime)
  void _startTrackingUpdateTimer() {
    _stopTrackingUpdateTimer(); // Stop any existing timer
    _trackingUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // This will trigger UI updates for tracking duration display every 500ms
      if (isTrackingEnabled.value) {
        // Force reactive update of all tracking related observables
        currentTrackingData.refresh();
        trackingHistory.refresh();
        // This triggers the getter trackingStatusText to update
        isTrackingEnabled.refresh();
      }
    });
  }

  /// Stop tracking update timer
  void _stopTrackingUpdateTimer() {
    _trackingUpdateTimer?.cancel();
    _trackingUpdateTimer = null;
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

      // Get current location (use fresh location for accurate capture)
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

      // Save image to device gallery
      await _cameraService.saveImageToGallery(
        imageBase64,
        filename: '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Start location tracking AFTER successful image capture for checkin
      bool trackingStarted = false;
      if (type == 'checkin') {
        trackingStarted = await _startLocationTracking();
      }

      // Create enhanced image data with tracking info
      final imageData = await _createEnhancedImageData(type, imageBase64);
      capturedImages.insert(0, imageData);

      // Update local state
      checkinStatus.value = type == 'checkin' ? CheckinStatus.checkedIn : CheckinStatus.notCheckedIn;

      // For checkout, stop location tracking
      if (type == 'checkout' && isTrackingEnabled.value) {
        await stopLocationTracking();
      }

      // Clear notes
      notes.clear();

      // Single consolidated success message
      String successMessage;
      if (type == 'checkin') {
        if (trackingStarted) {
          successMessage = "Checkin successful! Location tracking is now active.";
        } else {
          successMessage = "Checkin completed but location tracking failed to start.";
        }
      } else {
        successMessage = "Checkout completed successfully.";
      }

      Get.snackbar(
        "Success",
        successMessage,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to perform $type: $e");
      _resetCheckinStatus();
    } finally {
      isLoading.value = false;
    }
  }

  /// Create enhanced image data with tracking information
  Future<Map<String, dynamic>> _createEnhancedImageData(String type, String imageBase64) async {
    final baseData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'latitude': currentPosition.value!.latitude,
      'longitude': currentPosition.value!.longitude,
      'address': currentAddress.value,
      'imageBase64': imageBase64,
      'timestamp': DateTime.now().toIso8601String(),
      'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
      'isOnline': isOnline.value,
      'connectionType': connectionType.value,
    };

    // Add tracking information if available
    if (isTrackingEnabled.value) {
      final trackingStats = _trackingService.getTrackingStats();
      baseData.addAll({
        'hasTracking': true,
        'trackingDuration': _trackingService.trackingDurationText,
        'trackingStats': trackingStats,
        'trackingStartTime': _trackingService.trackingStartTime.value?.toIso8601String(),
      });
    } else {
      baseData['hasTracking'] = false;
    }

    return baseData;
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

  /// Force refresh location
  Future<void> refreshLocation() async {
    if (isTrackingEnabled.value) {
      Get.snackbar(
        'Location Update',
        'Location updates automatically during tracking',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      await getCurrentLocation();
    }
  }

  /// Get tracking statistics
  Map<String, dynamic> getTrackingStatistics() {
    return _trackingService.getTrackingStats();
  }

  /// Get connection information
  Map<String, dynamic> getConnectionInfo() {
    return _connectivityService.getConnectionInfo();
  }

  bool get canCheckin => checkinStatus.value == CheckinStatus.notCheckedIn;
  bool get canCheckout => checkinStatus.value == CheckinStatus.checkedIn;
  bool get isProcessing => checkinStatus.value == CheckinStatus.processing;

  String get statusText {
    switch (checkinStatus.value) {
      case CheckinStatus.notCheckedIn:
        return 'Not Checked In';
      case CheckinStatus.checkedIn:
        return 'Checked In${isTrackingEnabled.value ? ' (Tracking)' : ''}';
      case CheckinStatus.processing:
        return 'Processing...';
    }
  }

  String get trackingStatusText {
    if (!isTrackingEnabled.value) return 'Tracking Inactive';
    return 'Tracking Active';
  }

  String get trackingDurationText {
    if (!isTrackingEnabled.value) return '00:00:00';
    return _trackingService.trackingDurationText;
  }

  String? get lastActionTime {
    if (capturedImages.isEmpty) return null;
    final timestamp = DateTime.parse(capturedImages.first['timestamp']);
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _trackingSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _stopTrackingUpdateTimer();
    notes.dispose();
    super.onClose();
  }
}
