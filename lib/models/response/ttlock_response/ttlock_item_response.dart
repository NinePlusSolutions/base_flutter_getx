import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ttlock_item_response.g.dart';

@JsonSerializable()
class TTLockInitializedItem {
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

  TTLockInitializedItem({
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

  factory TTLockInitializedItem.fromJson(Map<String, dynamic> json) => _$TTLockInitializedItemFromJson(json);

  Map<String, dynamic> toJson() => _$TTLockInitializedItemToJson(this);

  // create a copy of the object with new values
  TTLockInitializedItem copyWith({
    int? lockId,
    String? lockName,
    String? lockAlias,
    String? lockMac,
    int? electricQuantity,
    String? featureValue,
    int? hasGateway,
    String? lockData,
    int? groupId,
    String? groupName,
    int? date,
  }) {
    return TTLockInitializedItem(
      lockId: lockId ?? this.lockId,
      lockName: lockName ?? this.lockName,
      lockAlias: lockAlias ?? this.lockAlias,
      lockMac: lockMac ?? this.lockMac,
      electricQuantity: electricQuantity ?? this.electricQuantity,
      featureValue: featureValue ?? this.featureValue,
      hasGateway: hasGateway ?? this.hasGateway,
      lockData: lockData ?? this.lockData,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! TTLockInitializedItem) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => lockId.hashCode ^ lockName.hashCode ^ lockMac.hashCode ^ lockData.hashCode;
}
