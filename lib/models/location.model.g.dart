// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  province: json['province'] as String,
  district: json['district'] as String,
  sector: json['sector'] as String,
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'province': instance.province,
  'district': instance.district,
  'sector': instance.sector,
};
