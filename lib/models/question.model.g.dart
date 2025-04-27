// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: json['_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  questionText: json['questionText'] as String,
  questionType: json['questionType'] as String,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  createdBy: json['createdBy'] as String?,
  isActive: json['isActive'] as bool?,
  surveyId: json['surveyTool'] as String,
  orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  version: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'questionText': instance.questionText,
  'questionType': instance.questionType,
  'options': instance.options,
  'createdBy': instance.createdBy,
  'isActive': instance.isActive,
  'surveyTool': instance.surveyId,
  'orderIndex': instance.orderIndex,
  if (instance.createdAt?.toIso8601String() case final value?)
    'createdAt': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updatedAt': value,
  if (instance.version case final value?) '__v': value,
};
