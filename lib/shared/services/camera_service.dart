import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

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
  }) async {
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile picture = await _controller!.takePicture();

      // Add watermark to image
      final watermarkedImagePath = await _addWatermarkToImage(
        picture.path,
        location: location,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
      );

      // Convert to base64
      if (watermarkedImagePath != null) {
        final bytes = await File(watermarkedImagePath).readAsBytes();
        return base64Encode(bytes);
      }

      return null;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  Future<String?> _addWatermarkToImage(
    String imagePath, {
    required String location,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Read the image
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return null;

      // Create watermark text
      final watermarkText = [
        'Time: ${timestamp.toString().substring(0, 19)}',
        'Location: $location',
        'GPS: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
      ].join('\n');

      // Add text watermark (simplified version)
      // Note: For better text rendering, consider using a more sophisticated image processing library
      // For now, we'll just return the original image and handle watermark in UI layer
      final img.Image watermarkedImage = img.copyResize(
        originalImage,
        width: originalImage.width,
        height: originalImage.height,
      );

      // TODO: Implement proper text watermarking
      debugPrint('Watermark text: $watermarkText');

      // Save watermarked image
      final Directory tempDir = await getTemporaryDirectory();
      final String watermarkedPath = '${tempDir.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(watermarkedPath).writeAsBytes(img.encodeJpg(watermarkedImage));

      // Clean up original
      await imageFile.delete();

      return watermarkedPath;
    } catch (e) {
      debugPrint('Error adding watermark: $e');
      return null;
    }
  }

  void disposeCamera() {
    _controller?.dispose();
    _controller = null;
  }
}
