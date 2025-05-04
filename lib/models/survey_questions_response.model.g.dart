// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_questions_response.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyQuestionsResponse _$SurveyQuestionsResponseFromJson(
  Map<String, dynamic> json,
) => SurveyQuestionsResponse(
  success: json['success'] as bool,
  data: SurveyQuestionsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SurveyQuestionsResponseToJson(
  SurveyQuestionsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data.toJson(),
};

SurveyQuestionsData _$SurveyQuestionsDataFromJson(Map<String, dynamic> json) =>
    SurveyQuestionsData(
      toolTitle: json['toolTitle'] as String,
      toolDescription: json['toolDescription'] as String,
      questions:
          (json['questions'] as List<dynamic>)
              .map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$SurveyQuestionsDataToJson(
  SurveyQuestionsData instance,
) => <String, dynamic>{
  'toolTitle': instance.toolTitle,
  'toolDescription': instance.toolDescription,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
};
