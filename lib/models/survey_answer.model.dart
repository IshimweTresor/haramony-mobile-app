import 'package:json_annotation/json_annotation.dart';
import 'location.model.dart';

part 'survey_answer.model.g.dart';

@JsonSerializable(explicitToJson: true)
class SurveyAnswer {
  final String questionId;
  
  // Single response field for both open and closed questions
  @JsonKey(includeIfNull: false)
  final String? response;
  
  // Location information
  final Location location;

  SurveyAnswer({
    required this.questionId,
    this.response,
    required this.location,
  });

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) => _$SurveyAnswerFromJson(json);
  
  Map<String, dynamic> toJson() => _$SurveyAnswerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SurveySubmission {
  final String surveyId;
  final String userId;
  final List<SurveyAnswer> answers;

  SurveySubmission({
    required this.surveyId,
    required this.userId,
    required this.answers,
  });

  factory SurveySubmission.fromJson(Map<String, dynamic> json) => _$SurveySubmissionFromJson(json);
  
  Map<String, dynamic> toJson() => _$SurveySubmissionToJson(this);
}