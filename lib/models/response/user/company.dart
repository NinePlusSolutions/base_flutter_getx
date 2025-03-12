import 'package:json_annotation/json_annotation.dart';

import 'address.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  final String? department;
  final String? name;
  final String? title;
  final Address? address;

  const Company({this.department, this.name, this.title, this.address});

  factory Company.fromJson(Map<String, dynamic> json) {
    return _$CompanyFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CompanyToJson(this);

  Company copyWith({
    String? department,
    String? name,
    String? title,
    Address? address,
  }) {
    return Company(
      department: department ?? this.department,
      name: name ?? this.name,
      title: title ?? this.title,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [department, name, title, address];
}
