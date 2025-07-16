import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/connectivity_service.dart';

/// Location tracking model
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
        'altitude': position.altitude,
        'speed': position.speed,
        'heading': position.heading,
        'address': address,
        'timestamp': timestamp.toIso8601String(),
        'isOnline': isOnline,
      };
}

/// Simplified realtime location tracking service
class LocationTrackingService extends GetxService {
  final LocationService _locationService = Get.find<LocationService>();
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();

  // Streams and controllers
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  final StreamController<LocationTrackingData> _trackingController = StreamController<LocationTrackingData>.broadcast();

  // Observable states
  final isTracking = false.obs;
  final currentTrackingData = Rx<LocationTrackingData?>(null);
  final trackingHistory = <LocationTrackingData>[].obs;
  final lastKnownPosition = Rx<Position?>(null);
  final isOnline = true.obs;
  final trackingStartTime = Rx<DateTime?>(null);
  Timer? _durationUpdateTimer;

  // Simplified configuration
  static const double _distanceFilter = 10.0; // meters
  static const int _maxHistoryItems = 50; // Reduced for simplicity
  static const LocationAccuracy _desiredAccuracy = LocationAccuracy.high;

  // Getters
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

  @override
  void onInit() {
    super.onInit();
    _initializeConnectivityMonitoring();
  }

  /// Initialize connectivity monitoring
  void _initializeConnectivityMonitoring() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        final wasOffline = !isOnline.value;
        isOnline.value = isConnected;

        if (wasOffline && isConnected && isTracking.value) {
          // Reconnected - update location immediately
          _updateLocationImmediately();
          Get.snackbar(
            'Connection Restored',
            'Location tracking resumed',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        } else if (!isConnected && isTracking.value) {
          // Disconnected - show warning
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
  }

  /// Start location tracking
  Future<bool> startTracking() async {
    try {
      if (isTracking.value) {
        debugPrint('Location tracking is already active');
        return true;
      }

      // Check permissions
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Required',
          'Location permission is required for tracking',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Check location services
      final locationEnabled = await _locationService.isLocationServicesEnabled();
      if (!locationEnabled) {
        Get.snackbar(
          'Location Services Disabled',
          'Please enable location services',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: () => _locationService.openLocationSettings(),
            child: const Text('Settings', style: TextStyle(color: Colors.white)),
          ),
        );
        return false;
      }

      // Get initial position
      final initialPosition = await _locationService.getCurrentLocation();
      if (initialPosition == null) {
        Get.snackbar('Error', 'Failed to get initial location');
        return false;
      }

      // Start tracking
      isTracking.value = true;
      trackingStartTime.value = DateTime.now();
      lastKnownPosition.value = initialPosition;

      // Clear previous tracking data
      trackingHistory.clear();

      // Initialize with current position
      await _updateLocationData(initialPosition, forceUpdate: true);

      // Start position stream
      _startPositionStream();

      // Start duration update timer
      _startDurationUpdateTimer();

      return true;
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      Get.snackbar('Error', 'Failed to start location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    try {
      if (!isTracking.value) {
        debugPrint('Location tracking is not active');
        return;
      }

      // Cancel subscription
      await _positionSubscription?.cancel();
      _positionSubscription = null;

      // Stop duration timer
      _stopDurationUpdateTimer();

      // Update state
      isTracking.value = false;
      trackingStartTime.value = null;

      debugPrint('Location tracking stopped. Total tracked locations: ${trackingHistory.length}');
    } catch (e) {
      debugPrint('Error stopping location tracking: $e');
    }
  }

  /// Start position stream with simplified configuration
  void _startPositionStream() {
    final locationSettings = LocationSettings(
      accuracy: _desiredAccuracy,
      distanceFilter: _distanceFilter.toInt(),
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _updateLocationData(position);
      },
      onError: (error) {
        debugPrint('Position stream error: $error');
        if (isTracking.value) {
          // Try to restart stream after error
          Timer(const Duration(seconds: 5), () {
            if (isTracking.value) {
              _startPositionStream();
            }
          });
        }
      },
    );
  }

  /// Update location data and notify listeners
  Future<void> _updateLocationData(Position position, {bool forceUpdate = false}) async {
    try {
      // Check if we should update based on distance or time
      if (!forceUpdate && lastKnownPosition.value != null) {
        final distance = Geolocator.distanceBetween(
          lastKnownPosition.value!.latitude,
          lastKnownPosition.value!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance < _distanceFilter) {
          return; // Skip update if distance is too small
        }
      }

      lastKnownPosition.value = position;

      // Get address (only if online for accuracy)
      String address = 'Unknown Location';
      if (isOnline.value) {
        try {
          address = await _locationService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
        } catch (e) {
          debugPrint('Error getting address: $e');
          // Use last known address if available
          address = currentTrackingData.value?.address ?? 'Unknown Location';
        }
      } else {
        // Use last known address when offline
        address = currentTrackingData.value?.address ?? 'Location unavailable (offline)';
      }

      // Create tracking data
      final trackingData = LocationTrackingData(
        position: position,
        address: address,
        timestamp: DateTime.now(),
        isOnline: isOnline.value,
      );

      // Update current data
      currentTrackingData.value = trackingData;

      // Add to history
      trackingHistory.insert(0, trackingData);

      // Limit history size
      if (trackingHistory.length > _maxHistoryItems) {
        trackingHistory.removeRange(_maxHistoryItems, trackingHistory.length);
      }

      // Notify listeners
      _trackingController.add(trackingData);

      debugPrint('Location updated: ${position.latitude}, ${position.longitude} - $address');
    } catch (e) {
      debugPrint('Error updating location data: $e');
    }
  }

  /// Force immediate location update
  Future<void> _updateLocationImmediately() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        await _updateLocationData(position, forceUpdate: true);
      }
    } catch (e) {
      debugPrint('Error in immediate location update: $e');
    }
  }

  /// Get basic tracking statistics (simplified)
  Map<String, dynamic> getTrackingStats() {
    return {
      'locationCount': trackingHistory.length,
      'totalTime': trackingDuration ?? Duration.zero,
      'isActive': isTracking.value,
    };
  }

  /// Clear tracking history
  void clearHistory() {
    trackingHistory.clear();
    currentTrackingData.value = null;
  }

  /// Start duration update timer for realtime duration display (more frequent)
  void _startDurationUpdateTimer() {
    _stopDurationUpdateTimer(); // Stop any existing timer
    _durationUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Force reactive update of trackingDurationText every 500ms for smooth updates
      if (trackingStartTime.value != null) {
        trackingStartTime.refresh();
      }
    });
  }

  /// Stop duration update timer
  void _stopDurationUpdateTimer() {
    _durationUpdateTimer?.cancel();
    _durationUpdateTimer = null;
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _stopDurationUpdateTimer();
    _trackingController.close();
    super.onClose();
  }
}
