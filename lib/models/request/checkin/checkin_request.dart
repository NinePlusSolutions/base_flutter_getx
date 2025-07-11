import 'package:json_annotation/json_annotation.dart';

part 'checkin_request.g.dart';

@JsonSerializable()
class CheckinRequest {
  final String type; // 'checkin' or 'checkout'
  final double latitude;
  final double longitude;
  final String address;
  final String imageBase64;
  final DateTime timestamp;
  final String? notes;

  CheckinRequest({
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.imageBase64,
    required this.timestamp,
    this.notes,
  });

  factory CheckinRequest.fromJson(Map<String, dynamic> json) => _$CheckinRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckinRequestToJson(this);
}
