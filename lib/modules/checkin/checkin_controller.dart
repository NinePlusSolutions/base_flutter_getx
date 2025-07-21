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
  // Core services
  final CameraService _cameraService = Get.find<CameraService>();
  final LocationService _locationService = Get.find<LocationService>();
  late final LocationTrackingService _trackingService;
  late final ConnectivityService _connectivityService;

  // Core state
  final checkinStatus = CheckinStatus.notCheckedIn.obs;
  final isLoading = false.obs;
  final notes = TextEditingController();

  // Location data - simplified
  final currentPosition = Rx<Position?>(null);
  final currentAddress = ''.obs;

  // Tracking state - simplified
  final isTrackingActive = false.obs;
  final trackingDuration = '00:00:00'.obs;

  // Connectivity
  final isOnline = true.obs;
  final connectionType = 'Unknown'.obs;

  // History - simplified structure
  final checkinHistory = <Map<String, dynamic>>[].obs;

  // Stream subscriptions
  StreamSubscription<LocationTrackingData>? _trackingSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _setupListeners();
    _loadCurrentLocation();
  }

  /// Initialize services
  void _initializeServices() {
    _connectivityService = Get.find<ConnectivityService>();
    _trackingService = Get.find<LocationTrackingService>();
  }

  /// Setup essential listeners only
  void _setupListeners() {
    // Track location updates
    _trackingSubscription = _trackingService.trackingStream.listen(
      (data) => _updateLocationFromTracking(data),
      onError: (error) => debugPrint('Tracking error: $error'),
    );

    // Track connectivity
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (connected) => _updateConnectivity(connected),
    );

    // Track tracking status
    ever(_trackingService.isTracking, (bool isTracking) {
      isTrackingActive.value = isTracking;
      if (isTracking) {
        _startDurationUpdates();
      } else {
        _stopDurationUpdates();
      }
    });

    // Initialize connectivity state
    isOnline.value = _connectivityService.isConnected.value;
    connectionType.value = _connectivityService.connectionTypeText;
  }

  /// Update location from tracking service
  void _updateLocationFromTracking(LocationTrackingData data) {
    currentPosition.value = data.position;
    currentAddress.value = data.address;
  }

  /// Update connectivity state
  void _updateConnectivity(bool connected) {
    isOnline.value = connected;
    connectionType.value = _connectivityService.connectionTypeText;

    if (!connected && isTrackingActive.value) {
      _showConnectivityMessage('Offline mode - tracking continues', Colors.orange);
    } else if (connected && isTrackingActive.value) {
      _showConnectivityMessage('Online - tracking resumed', Colors.green);
    }
  }

  /// Load current location
  Future<void> _loadCurrentLocation() async {
    if (isTrackingActive.value) return; // Use tracking data if available

    try {
      isLoading.value = true;
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        currentPosition.value = position;
        currentAddress.value = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      _showError('Failed to get location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Perform checkin
  Future<void> performCheckin() async {
    await _performAction('checkin');
  }

  /// Perform checkout
  Future<void> performCheckout() async {
    await _performAction('checkout');
  }

  /// Core action handler - simplified
  Future<void> _performAction(String actionType) async {
    try {
      isLoading.value = true;
      checkinStatus.value = CheckinStatus.processing;

      // Validate permissions and location
      if (!await _validateRequirements()) {
        _resetStatus();
        return;
      }

      // Capture image
      final imageBase64 = await _captureImage(actionType);
      if (imageBase64 == null) {
        _resetStatus();
        return;
      }

      // Handle tracking based on action
      await _handleTracking(actionType);

      // Save record
      _saveActionRecord(actionType, imageBase64);

      // Update status
      _updateStatusAfterAction(actionType);

      // Show success
      _showSuccessMessage(actionType);
    } catch (e) {
      _showError('$actionType failed: $e');
      _resetStatus();
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate requirements
  Future<bool> _validateRequirements() async {
    // Check camera permission
    if (!await _cameraService.requestCameraPermission()) {
      _showError('Camera permission required');
      return false;
    }

    // Ensure location is available
    await _loadCurrentLocation();
    if (currentPosition.value == null) {
      _showError('Location not available');
      return false;
    }

    return true;
  }

  /// Capture image
  Future<String?> _captureImage(String actionType) async {
    return await Get.to<String>(
      () => _buildCameraScreen(actionType),
      fullscreenDialog: true,
    );
  }

  /// Handle tracking based on action
  Future<void> _handleTracking(String actionType) async {
    if (actionType == 'checkin') {
      final success = await _trackingService.startTracking();
      if (!success) {
        debugPrint('Warning: Tracking failed to start');
      }
    } else if (actionType == 'checkout') {
      await _trackingService.stopTracking();
    }
  }

  /// Save action record - simplified
  void _saveActionRecord(String actionType, String imageBase64) {
    final record = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': actionType,
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': currentPosition.value!.latitude,
      'longitude': currentPosition.value!.longitude,
      'address': currentAddress.value,
      'imageBase64': imageBase64,
      'notes': notes.text.trim().isNotEmpty ? notes.text.trim() : null,
      'isOnline': isOnline.value,
    };

    checkinHistory.insert(0, record);

    // Save to gallery
    _cameraService.saveImageToGallery(
      imageBase64,
      filename: '${actionType}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Clear notes
    notes.clear();
  }

  /// Update status after action
  void _updateStatusAfterAction(String actionType) {
    checkinStatus.value = actionType == 'checkin' ? CheckinStatus.checkedIn : CheckinStatus.notCheckedIn;
  }

  /// Camera screen builder
  Widget _buildCameraScreen(String actionType) {
    return Scaffold(
      body: CameraPreviewWidget(
        locationText: currentAddress.value,
        gpsText: currentPosition.value != null
            ? '${currentPosition.value!.latitude.toStringAsFixed(6)}, ${currentPosition.value!.longitude.toStringAsFixed(6)}'
            : null,
        latitude: currentPosition.value?.latitude,
        longitude: currentPosition.value?.longitude,
        notes: notes.text.trim().isNotEmpty ? notes.text.trim() : null,
        onCapture: (imageBase64) => Get.back(result: imageBase64),
        onCancel: () => Get.back(),
      ),
    );
  }

  /// Duration updates for tracking display
  Timer? _durationTimer;
  void _startDurationUpdates() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      trackingDuration.value = _trackingService.trackingDurationText;
    });
  }

  void _stopDurationUpdates() {
    _durationTimer?.cancel();
    _durationTimer = null;
    trackingDuration.value = '00:00:00';
  }

  /// Utility methods
  void _resetStatus() {
    checkinStatus.value = checkinHistory.isNotEmpty && checkinHistory.first['type'] == 'checkin'
        ? CheckinStatus.checkedIn
        : CheckinStatus.notCheckedIn;
  }

  void _showError(String message) {
    Get.snackbar('Error', message, backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _showSuccessMessage(String actionType) {
    final message = actionType == 'checkin'
        ? 'Checked in successfully! Tracking started.'
        : 'Checked out successfully! Tracking stopped.';
    Get.snackbar('Success', message, backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _showConnectivityMessage(String message, Color color) {
    Get.snackbar('Connection', message,
        backgroundColor: color, colorText: Colors.white, duration: const Duration(seconds: 2));
  }

  /// Public getters - simplified
  bool get canCheckin => checkinStatus.value == CheckinStatus.notCheckedIn;
  bool get canCheckout => checkinStatus.value == CheckinStatus.checkedIn;

  String get statusText {
    switch (checkinStatus.value) {
      case CheckinStatus.notCheckedIn:
        return 'Ready to Check In';
      case CheckinStatus.checkedIn:
        return 'Checked In${isTrackingActive.value ? ' (Tracking)' : ''}';
      case CheckinStatus.processing:
        return 'Processing...';
    }
  }

  String? get lastActionTime {
    if (checkinHistory.isEmpty) return null;
    final timestamp = DateTime.parse(checkinHistory.first['timestamp']);
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Public methods
  Future<void> refreshLocation() async {
    if (!isTrackingActive.value) {
      await _loadCurrentLocation();
    }
  }

  void viewImageFullScreen(Map<String, dynamic> imageData) {
    Get.to(
        () => ImageViewerWidget(
              imageBase64: imageData['imageBase64'],
              imageData: imageData,
            ),
        fullscreenDialog: true);
  }

  void deleteRecord(String recordId) {
    checkinHistory.removeWhere((record) => record['id'] == recordId);
    Get.snackbar('Success', 'Record deleted');
  }

  Map<String, dynamic> getConnectionInfo() => _connectivityService.getConnectionInfo();
  Map<String, dynamic> getTrackingStats() => _trackingService.getTrackingStats();

  @override
  void onClose() {
    _trackingSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _durationTimer?.cancel();
    notes.dispose();
    super.onClose();
  }
}
