import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_getx_boilerplate/shared/services/watermark_service.dart';
import 'package:gal/gal.dart';

class CameraService extends GetxService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool get isInitialized => _controller?.value.isInitialized ?? false;
  CameraController? get controller => _controller;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initCameras();
  }

  @override
  void onClose() {
    _controller?.dispose();
    super.onClose();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> initializeCamera() async {
    if (_cameras.isEmpty) {
      await _initCameras();
    }

    if (_cameras.isEmpty) {
      return false;
    }

    try {
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      return true;
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      return false;
    }
  }

  Future<String?> takePictureWithWatermark({
    required String location,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile picture = await _controller!.takePicture();

      // Read image bytes
      final Uint8List imageBytes = await picture.readAsBytes();

      // Add watermark using the new service
      final Uint8List watermarkedImageBytes = await WatermarkService.addTextWatermarkToImage(
        imageBytes: imageBytes,
        location: location,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );

      // Convert to base64
      final String base64Image = base64Encode(watermarkedImageBytes);

      // Clean up original file
      await File(picture.path).delete();

      return base64Image;
    } catch (e) {
      debugPrint('Error taking picture with watermark: $e');
      return null;
    }
  }

  // Save image to device gallery
  Future<bool> saveImageToGallery(String base64Image, {String? filename}) async {
    try {
      final bytes = base64Decode(base64Image);

      // Request storage permission using Gal's built-in permission handler
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
        // Check again after requesting
        final hasAccessAfterRequest = await Gal.hasAccess();
        if (!hasAccessAfterRequest) {
          debugPrint('Gallery access permission denied');
          return false;
        }
      }

      // Create filename if not provided
      final String fileName = filename ?? 'Checkin_${DateTime.now().millisecondsSinceEpoch}';

      // Save to device gallery using Gal
      await Gal.putImageBytes(
        bytes,
        name: fileName,
      );

      debugPrint('Image saved to gallery successfully: $fileName');
      return true;
    } catch (e) {
      debugPrint('Error saving image to gallery: $e');
      return false;
    }
  }

  void disposeCamera() {
    _controller?.dispose();
    _controller = null;
  }
}
