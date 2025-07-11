import 'package:json_annotation/json_annotation.dart';

part 'checkin_response.g.dart';

@JsonSerializable()
class CheckinResponse {
  final String id;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String imageUrl;
  final DateTime timestamp;
  final String? notes;
  final String status;
  final DateTime createdAt;

  CheckinResponse({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.imageUrl,
    required this.timestamp,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory CheckinResponse.fromJson(Map<String, dynamic> json) => _$CheckinResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CheckinResponseToJson(this);
}
