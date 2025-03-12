import 'package:json_annotation/json_annotation.dart';

part 'hair.g.dart';

@JsonSerializable()
class Hair {
  final String? color;
  final String? type;

  const Hair({this.color, this.type});

  factory Hair.fromJson(Map<String, dynamic> json) => _$HairFromJson(json);

  Map<String, dynamic> toJson() => _$HairToJson(this);

  Hair copyWith({
    String? color,
    String? type,
  }) {
    return Hair(
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [color, type];
}
