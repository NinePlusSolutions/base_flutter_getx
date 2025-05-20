import 'package:json_annotation/json_annotation.dart';

import 'ttlock_item_response.dart';
part 'ttlock_list_response.g.dart';

@JsonSerializable()
class TTLockListResponse {
  final List<TTLockInitializedItem> list;
  final int pageNo;
  final int pageSize;
  final int pages;
  final int total;

  TTLockListResponse({
    required this.list,
    required this.pageNo,
    required this.pageSize,
    required this.pages,
    required this.total,
  });

  factory TTLockListResponse.fromJson(Map<String, dynamic> json) => _$TTLockListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TTLockListResponseToJson(this);
}
