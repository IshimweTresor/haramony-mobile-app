// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_tool.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyTool _$SurveyToolFromJson(Map<String, dynamic> json) => SurveyTool(
  id: json['_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  createdBy: json['createdBy'] as String,
  isActive: json['isActive'] as bool,
  validFrom:
      json['validFrom'] == null
          ? null
          : DateTime.parse(json['validFrom'] as String),
  validUntil:
      json['validUntil'] == null
          ? null
          : DateTime.parse(json['validUntil'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  version: (json['__v'] as num).toInt(),
  questions:
      (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
  isCurrentlyActive: json['isCurrentlyActive'] as bool,
);

Map<String, dynamic> _$SurveyToolToJson(SurveyTool instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdBy': instance.createdBy,
      'isActive': instance.isActive,
      if (instance.validFrom?.toIso8601String() case final value?)
        'validFrom': value,
      if (instance.validUntil?.toIso8601String() case final value?)
        'validUntil': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      '__v': instance.version,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'isCurrentlyActive': instance.isCurrentlyActive,
    };
