import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/services/camera_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/storage_service.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/camera/camera_preview_widget.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/image/image_viewer_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'models/issue_report_model.dart';

class IssueReportController extends GetxController {
  final CameraService _cameraService = Get.find<CameraService>();
  final LocationService _locationService = Get.find<LocationService>();

  final isLoading = false.obs;
  final issueDescription = TextEditingController();
  final issueType = IssueType.safety.obs;
  final issuePriority = IssuePriority.medium.obs;

  // Current location data
  final currentPosition = Rx<Position?>(null);
  final currentAddress = ''.obs;

  // List to store issue reports
  final issueReports = <IssueReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
    _loadStoredReports();
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

  Future<void> submitIssueReport() async {
    if (issueDescription.text.trim().isEmpty) {
      Get.snackbar("Validation Error", "Please provide issue description");
      return;
    }

    try {
      isLoading.value = true;

      // Check camera permission
      final hasCameraPermission = await _cameraService.requestCameraPermission();
      if (!hasCameraPermission) {
        Get.snackbar("Permission Required", "Camera permission is required for issue reporting");
        return;
      }

      // Get current location
      await getCurrentLocation();
      if (currentPosition.value == null) {
        Get.snackbar("Location Error", "Failed to get current location");
        return;
      }

      // Navigate to camera screen
      final imageBase64 = await Get.to<String>(
        () => _buildCameraScreen(),
        fullscreenDialog: true,
      );

      if (imageBase64 == null) {
        return;
      }

      // Create issue report model
      final issueModel = IssueReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        issueType: issueType.value,
        priority: issuePriority.value,
        description: issueDescription.text.trim(),
        latitude: currentPosition.value!.latitude,
        longitude: currentPosition.value!.longitude,
        address: currentAddress.value,
        imageBase64: imageBase64,
        timestamp: DateTime.now(),
        status: IssueStatus.pending,
      );

      // Add to list and save locally
      issueReports.insert(0, issueModel);
      await _saveReportsLocally();

      // Save image to device gallery
      final savedToGallery = await _cameraService.saveImageToGallery(
        imageBase64,
        filename: 'IssueReport_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (savedToGallery) {
        debugPrint('Issue report image saved to gallery successfully');
      }

      // Clear form
      issueDescription.clear();
      issueType.value = IssueType.safety;
      issuePriority.value = IssuePriority.medium;

      Get.snackbar(
        "Success",
        "Issue report submitted successfully${savedToGallery ? ' and saved to gallery' : ''}",
      );

      // Navigate back or to history
      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to submit issue report: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildCameraScreen() {
    return Scaffold(
      body: CameraPreviewWidget(
        locationText: currentAddress.value,
        gpsText: currentPosition.value != null
            ? '${currentPosition.value!.latitude.toStringAsFixed(6)}, ${currentPosition.value!.longitude.toStringAsFixed(6)}'
            : null,
        latitude: currentPosition.value?.latitude,
        longitude: currentPosition.value?.longitude,
        notes:
            'Issue: ${issueType.value.name.toUpperCase()} - ${issuePriority.value.name.toUpperCase()}\\n${issueDescription.text.trim()}',
        onCapture: (imageBase64) async {
          Get.back(result: imageBase64);
        },
        onCancel: () {
          Get.back();
        },
      ),
    );
  }

  void viewImageFullScreen(IssueReportModel issueModel) {
    Get.to(
      () => ImageViewerWidget(
        imageBase64: issueModel.imageBase64,
        imageData: issueModel.toJson(),
      ),
      fullscreenDialog: true,
      transition: Transition.fadeIn,
    );
  }

  void deleteIssueReport(String issueId) {
    issueReports.removeWhere((issue) => issue.id == issueId);
    _saveReportsLocally();
    Get.snackbar("Success", "Issue report deleted successfully");
  }

  void updateIssueStatus(String issueId, IssueStatus newStatus) {
    final index = issueReports.indexWhere((issue) => issue.id == issueId);
    if (index != -1) {
      final updatedIssue = issueReports[index].copyWith(
        status: newStatus,
        lastUpdated: DateTime.now(),
      );
      issueReports[index] = updatedIssue;
      _saveReportsLocally();
      Get.snackbar("Success", "Issue status updated to ${newStatus.displayName}");
    }
  }

  Future<void> _saveReportsLocally() async {
    try {
      final jsonList = issueReports.map((report) => report.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      StorageService.issueReportsJson = jsonString;
      debugPrint('Saved ${issueReports.length} issue reports locally');
    } catch (e) {
      debugPrint('Error saving reports locally: $e');
    }
  }

  Future<void> _loadStoredReports() async {
    try {
      final jsonString = StorageService.issueReportsJson;
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final reports = jsonList.map((json) => IssueReportModel.fromJson(Map<String, dynamic>.from(json))).toList();
        issueReports.assignAll(reports);
        debugPrint('Loaded ${issueReports.length} issue reports from local storage');
      }
    } catch (e) {
      debugPrint('Error loading stored reports: $e');
    }
  }

  // Getters for statistics
  int get totalReports => issueReports.length;
  int get pendingReports => issueReports.where((report) => report.status == IssueStatus.pending).length;
  int get inProgressReports => issueReports.where((report) => report.status == IssueStatus.inProgress).length;
  int get resolvedReports => issueReports.where((report) => report.status == IssueStatus.resolved).length;

  String getIssueTypeDisplayName(String type) {
    try {
      final issueType = IssueType.values.firstWhere((e) => e.name == type);
      return issueType.displayName;
    } catch (e) {
      return 'Unknown Issue';
    }
  }

  String getPriorityDisplayName(String priority) {
    try {
      final issuePriority = IssuePriority.values.firstWhere((e) => e.name == priority);
      return issuePriority.displayName;
    } catch (e) {
      return 'Unknown';
    }
  }

  Color getPriorityColor(String priority) {
    try {
      final issuePriority = IssuePriority.values.firstWhere((e) => e.name == priority);
      return issuePriority.color;
    } catch (e) {
      return Colors.grey;
    }
  }

  Color getStatusColor(String status) {
    try {
      final issueStatus = IssueStatus.values.firstWhere(
        (e) => e.name == status || e.name.replaceAll('Progress', '_progress').toLowerCase() == status,
      );
      return issueStatus.color;
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  void onClose() {
    issueDescription.dispose();
    super.onClose();
  }
}
