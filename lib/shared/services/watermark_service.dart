import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class WatermarkService {
  static Future<Uint8List> addTextWatermarkToImage({
    required Uint8List imageBytes,
    required String location,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    // Decode the image
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    // Create a recorder and canvas
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Size imageSize = Size(
      originalImage.width.toDouble(),
      originalImage.height.toDouble(),
    );

    // Draw the original image
    canvas.drawImage(originalImage, Offset.zero, Paint());

    // Create watermark overlay
    final double overlayHeight = imageSize.height * 0.15; // 15% of image height
    final Rect overlayRect = Rect.fromLTWH(
      0,
      imageSize.height - overlayHeight,
      imageSize.width,
      overlayHeight,
    );

    // Draw semi-transparent black overlay
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawRect(overlayRect, overlayPaint);

    // Text style
    final double fontSize = imageSize.width * 0.025; // Responsive font size
    final TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 2,
          color: Colors.black.withOpacity(0.8),
        ),
      ],
    );

    // Format text content
    final String formattedTime = _formatDateTime(timestamp);
    final String gpsText = '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

    final List<String> textLines = [
      '⏰ $formattedTime',
      '📍 $location',
      '🌐 $gpsText',
      if (notes != null && notes.isNotEmpty) '📝 $notes',
    ];

    // Draw text lines
    double yOffset = overlayRect.top + fontSize;
    for (String line in textLines) {
      final TextSpan textSpan = TextSpan(text: line, style: textStyle);
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );

      textPainter.layout(maxWidth: imageSize.width - 20);
      textPainter.paint(canvas, Offset(10, yOffset));
      yOffset += fontSize * 1.5;
    }

    // Convert to image
    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(
      imageSize.width.toInt(),
      imageSize.height.toInt(),
    );

    // Convert to bytes
    final ByteData? byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }

    return byteData.buffer.asUint8List();
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
