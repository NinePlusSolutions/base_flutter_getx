import 'package:json_annotation/json_annotation.dart';

part 'coordinates.g.dart';

@JsonSerializable()
class Coordinates {
  final double? lat;
  final double? lng;

  const Coordinates({this.lat, this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return _$CoordinatesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);

  Coordinates copyWith({
    double? lat,
    double? lng,
  }) {
    return Coordinates(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  List<Object?> get props => [lat, lng];
}
