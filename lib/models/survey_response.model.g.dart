// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_response.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyResponse _$SurveyResponseFromJson(Map<String, dynamic> json) =>
    SurveyResponse(
      success: json['success'] as bool,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => SurveyTool.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$SurveyResponseToJson(SurveyResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
