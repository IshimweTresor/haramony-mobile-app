// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_answer.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyAnswer _$SurveyAnswerFromJson(Map<String, dynamic> json) => SurveyAnswer(
  questionId: json['questionId'] as String,
  response: json['response'] as String?,
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SurveyAnswerToJson(SurveyAnswer instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      if (instance.response case final value?) 'response': value,
      'location': instance.location.toJson(),
    };

SurveySubmission _$SurveySubmissionFromJson(Map<String, dynamic> json) =>
    SurveySubmission(
      surveyId: json['surveyId'] as String,
      userId: json['userId'] as String,
      answers:
          (json['answers'] as List<dynamic>)
              .map((e) => SurveyAnswer.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$SurveySubmissionToJson(SurveySubmission instance) =>
    <String, dynamic>{
      'surveyId': instance.surveyId,
      'userId': instance.userId,
      'answers': instance.answers.map((e) => e.toJson()).toList(),
    };
