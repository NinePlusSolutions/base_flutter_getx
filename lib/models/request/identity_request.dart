import 'package:json_annotation/json_annotation.dart';

part 'identity_request.g.dart';

@JsonSerializable()
class IdentityRequest {
  final String identityCard;
  final DateTime provideDateIdentityCard;
  final String providePlaceIdentityCard;

  IdentityRequest({
    required this.identityCard,
    required this.provideDateIdentityCard,
    required this.providePlaceIdentityCard,
  });

  Map<String, dynamic> toJson() => _$IdentityRequestToJson(this);
}
