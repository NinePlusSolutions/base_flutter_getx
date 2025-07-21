import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/connectivity_service.dart';

/// Location tracking data model
class LocationTrackingData {
  final Position position;
  final String address;
  final DateTime timestamp;
  final bool isOnline;

  LocationTrackingData({
    required this.position,
    required this.address,
    required this.timestamp,
    required this.isOnline,
  });

  Map<String, dynamic> toJson() => {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'address': address,
        'timestamp': timestamp.toIso8601String(),
        'isOnline': isOnline,
      };
}

/// Simplified location tracking service focused on core functionality
class LocationTrackingService extends GetxService {
  final LocationService _locationService = Get.find<LocationService>();
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();

  // Core state
  final isTracking = false.obs;
  final trackingHistory = <LocationTrackingData>[].obs;
  final currentTrackingData = Rx<LocationTrackingData?>(null);
  final trackingStartTime = Rx<DateTime?>(null);

  // Configuration
  static const double _distanceFilter = 10.0; // meters
  static const int _maxHistoryItems = 100;
  static const LocationAccuracy _accuracy = LocationAccuracy.high;

  // Internal
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<LocationTrackingData> _trackingController = StreamController<LocationTrackingData>.broadcast();

  // Public getters
  Stream<LocationTrackingData> get trackingStream => _trackingController.stream;

  Duration? get trackingDuration {
    if (trackingStartTime.value == null) return null;
    return DateTime.now().difference(trackingStartTime.value!);
  }

  String get trackingDurationText {
    final duration = trackingDuration;
    if (duration == null) return '00:00:00';

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  /// Start location tracking
  Future<bool> startTracking() async {
    try {
      if (isTracking.value) {
        debugPrint('Tracking already active');
        return true;
      }

      // Validate permissions
      if (!await _validatePermissions()) return false;

      // Get initial position
      final initialPosition = await _locationService.getCurrentLocation();
      if (initialPosition == null) {
        _showError('Failed to get initial location');
        return false;
      }

      // Initialize tracking
      isTracking.value = true;
      trackingStartTime.value = DateTime.now();
      trackingHistory.clear();

      // Add initial position
      await _addLocationData(initialPosition, forceUpdate: true);

      // Start position stream
      _startPositionStream();

      debugPrint('Location tracking started');
      return true;
    } catch (e) {
      debugPrint('Error starting tracking: $e');
      _showError('Failed to start tracking');
      return false;
    }
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    try {
      if (!isTracking.value) return;

      _positionSubscription?.cancel();
      _positionSubscription = null;

      isTracking.value = false;
      trackingStartTime.value = null;

      debugPrint('Location tracking stopped. Total points: ${trackingHistory.length}');
    } catch (e) {
      debugPrint('Error stopping tracking: $e');
    }
  }

  /// Validate permissions and services
  Future<bool> _validatePermissions() async {
    // Check location permission
    if (!await _locationService.requestLocationPermission()) {
      _showError('Location permission required');
      return false;
    }

    // Check location services
    if (!await _locationService.isLocationServicesEnabled()) {
      _showError('Please enable location services');
      return false;
    }

    return true;
  }

  /// Start position stream
  void _startPositionStream() {
    final locationSettings = LocationSettings(
      accuracy: _accuracy,
      distanceFilter: _distanceFilter.toInt(),
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) => _addLocationData(position),
      onError: (error) {
        debugPrint('Position stream error: $error');
        // Auto-restart on error
        if (isTracking.value) {
          Future.delayed(const Duration(seconds: 5), () {
            if (isTracking.value) _startPositionStream();
          });
        }
      },
    );
  }

  /// Add location data to tracking
  Future<void> _addLocationData(Position position, {bool forceUpdate = false}) async {
    try {
      // Distance filter check
      if (!forceUpdate && trackingHistory.isNotEmpty) {
        final lastPosition = trackingHistory.first.position;
        final distance = Geolocator.distanceBetween(
          lastPosition.latitude,
          lastPosition.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance < _distanceFilter) return;
      }

      // Get address
      String address = 'Unknown Location';
      try {
        if (_connectivityService.isConnected.value) {
          address = await _locationService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
        } else {
          // Use last known address when offline
          address = currentTrackingData.value?.address ?? 'Location unavailable (offline)';
        }
      } catch (e) {
        debugPrint('Address lookup failed: $e');
        address = currentTrackingData.value?.address ?? 'Unknown Location';
      }

      // Create tracking data
      final trackingData = LocationTrackingData(
        position: position,
        address: address,
        timestamp: DateTime.now(),
        isOnline: _connectivityService.isConnected.value,
      );

      // Update state
      currentTrackingData.value = trackingData;
      trackingHistory.insert(0, trackingData);

      // Limit history size
      if (trackingHistory.length > _maxHistoryItems) {
        trackingHistory.removeRange(_maxHistoryItems, trackingHistory.length);
      }

      // Notify listeners
      _trackingController.add(trackingData);

      debugPrint('Location updated: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}');
    } catch (e) {
      debugPrint('Error adding location data: $e');
    }
  }

  /// Get basic statistics
  Map<String, dynamic> getTrackingStats() {
    if (trackingHistory.isEmpty) {
      return {
        'locationCount': 0,
        'totalDistance': 0.0,
        'averageSpeed': 0.0,
        'maxSpeed': 0.0,
        'isActive': isTracking.value,
      };
    }

    double totalDistance = 0.0;
    double maxSpeed = 0.0;
    double totalSpeed = 0.0;
    int validSpeedCount = 0;

    for (int i = 1; i < trackingHistory.length; i++) {
      final current = trackingHistory[i];
      final previous = trackingHistory[i - 1];

      // Calculate distance
      final distance = Geolocator.distanceBetween(
        previous.position.latitude,
        previous.position.longitude,
        current.position.latitude,
        current.position.longitude,
      );
      totalDistance += distance;

      // Track speed
      final speed = current.position.speed;
      if (speed >= 0) {
        maxSpeed = speed > maxSpeed ? speed : maxSpeed;
        totalSpeed += speed;
        validSpeedCount++;
      }
    }

    return {
      'locationCount': trackingHistory.length,
      'totalDistance': totalDistance,
      'averageSpeed': validSpeedCount > 0 ? totalSpeed / validSpeedCount : 0.0,
      'maxSpeed': maxSpeed,
      'isActive': isTracking.value,
    };
  }

  /// Clear tracking history
  void clearHistory() {
    trackingHistory.clear();
    currentTrackingData.value = null;
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Tracking Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _trackingController.close();
    super.onClose();
  }
}
