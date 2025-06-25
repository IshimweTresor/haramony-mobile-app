// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Issue _$IssueFromJson(Map<String, dynamic> json) => Issue(
  id: json['_id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  userId: Issue._parseIdField(json['userId']),
  categoryId: Issue._parseIdField(json['categoryId']),
  status: json['status'] as String? ?? 'Pending',
  location:
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  userInfo:
      json['userInfo'] == null
          ? null
          : User.fromJson(json['userInfo'] as Map<String, dynamic>),
  categoryInfo:
      json['categoryInfo'] == null
          ? null
          : Category.fromJson(json['categoryInfo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IssueToJson(Issue instance) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'userId': instance.userId,
  'categoryId': instance.categoryId,
  'status': instance.status,
  'location': instance.location,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  if (instance.userInfo case final value?) 'userInfo': value,
  if (instance.categoryInfo case final value?) 'categoryInfo': value,
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  sector: json['sector'] as String?,
  cell: json['cell'] as String?,
  village: json['village'] as String?,
  isibo: json['isibo'] as String?,
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'sector': instance.sector,
  'cell': instance.cell,
  'village': instance.village,
  'isibo': instance.isibo,
};
