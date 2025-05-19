import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ttlock_item_response.g.dart';

@JsonSerializable()
class TTLockItem {
  final int lockId;
  final String lockName;
  final String lockAlias;
  final String lockMac;
  final int electricQuantity;
  final String featureValue;
  final int hasGateway;
  final String lockData;
  final int? groupId;
  final String? groupName;
  final int date;

  TTLockItem({
    required this.lockId,
    required this.lockName,
    required this.lockAlias,
    required this.lockMac,
    required this.electricQuantity,
    required this.featureValue,
    required this.hasGateway,
    required this.lockData,
    this.groupId,
    this.groupName,
    required this.date,
  });

  factory TTLockItem.fromJson(Map<String, dynamic> json) => _$TTLockItemFromJson(json);

  Map<String, dynamic> toJson() => _$TTLockItemToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! TTLockItem) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => lockId.hashCode ^ lockName.hashCode ^ lockMac.hashCode ^ lockData.hashCode;
}
