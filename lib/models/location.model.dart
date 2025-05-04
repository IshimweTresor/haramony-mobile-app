import 'package:json_annotation/json_annotation.dart';

part 'location.model.g.dart';

@JsonSerializable()
class Location {
  final String province;
  final String district;
  final String sector;

  Location({
    required this.province,
    required this.district,
    required this.sector,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}