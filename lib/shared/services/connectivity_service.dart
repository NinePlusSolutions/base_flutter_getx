import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Simplified network connectivity service
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  // Observable states
  final isConnected = true.obs;
  final connectionType = ConnectivityResult.none.obs;

  // Getters
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool get hasInternetConnection => isConnected.value;

  String get connectionTypeText {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeConnectivityMonitoring();
  }

  /// Initialize connectivity monitoring
  void _initializeConnectivityMonitoring() {
    // Check initial connectivity
    _checkInitialConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        debugPrint('Connectivity stream error: $error');
      },
    );
  }

  /// Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final result = connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;

      _updateConnectivityStatus(result);
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
      _updateConnectivityStatus(ConnectivityResult.none);
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectivityStatus(result);
  }

  /// Update connectivity status
  void _updateConnectivityStatus(ConnectivityResult result) {
    final wasConnected = isConnected.value;
    final newConnectionStatus = result != ConnectivityResult.none;

    connectionType.value = result;
    isConnected.value = newConnectionStatus;

    if (newConnectionStatus && !wasConnected) {
      debugPrint('Connection established: ${connectionTypeText}');
    } else if (!newConnectionStatus && wasConnected) {
      debugPrint('Connection lost');
    }

    // Notify listeners
    _connectivityController.add(newConnectionStatus);
  }

  /// Manually check connectivity
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final result = connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;

      _updateConnectivityStatus(result);
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get simplified connection status info
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': isConnected.value,
      'connectionType': connectionTypeText,
    };
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
    super.onClose();
  }
}
