import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/services/camera_service.dart';
import 'package:get/get.dart';

class CameraPreviewWidget extends StatefulWidget {
  final Function(String imageBase64)? onCapture;
  final VoidCallback? onCancel;
  final String? locationText;
  final String? gpsText;
  final double? latitude;
  final double? longitude;
  final String? notes;

  const CameraPreviewWidget({
    super.key,
    this.onCapture,
    this.onCancel,
    this.locationText,
    this.gpsText,
    this.latitude,
    this.longitude,
    this.notes,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  final CameraService _cameraService = Get.find<CameraService>();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _cameraService.initializeCamera();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing || !_cameraService.isInitialized) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final imageBase64 = await _cameraService.takePictureWithWatermark(
        location: widget.locationText ?? 'Unknown Location',
        timestamp: DateTime.now(),
        latitude: widget.latitude ?? 0.0,
        longitude: widget.longitude ?? 0.0,
        notes: widget.notes,
      );

      if (imageBase64 != null && widget.onCapture != null) {
        widget.onCapture!(imageBase64);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      Get.snackbar('Error', 'Failed to capture image');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraService.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_cameraService.isInitialized)
            Positioned.fill(
              child: CameraPreview(_cameraService.controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Top overlay with info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Take Checkin Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  if (widget.locationText != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.locationText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.gpsText != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.gps_fixed,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.gpsText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateTime.now().toString().substring(0, 19),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom overlay with capture button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 32,
                top: 32,
                left: 32,
                right: 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _isCapturing ? null : _captureImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        color: _isCapturing ? Colors.grey.withOpacity(0.5) : Colors.transparent,
                      ),
                      child: _isCapturing
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
