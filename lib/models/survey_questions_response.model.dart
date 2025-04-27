import 'package:json_annotation/json_annotation.dart';
import 'question.model.dart';

part 'survey_questions_response.model.g.dart';

@JsonSerializable(explicitToJson: true)
class SurveyQuestionsResponse {
  final bool success;
  final SurveyQuestionsData data;

  SurveyQuestionsResponse({
    required this.success,
    required this.data,
  });

  factory SurveyQuestionsResponse.fromJson(Map<String, dynamic> json) => 
      _$SurveyQuestionsResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$SurveyQuestionsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SurveyQuestionsData {
  final String toolTitle;
  final String toolDescription;
  final List<Question> questions;

  SurveyQuestionsData({
    required this.toolTitle,
    required this.toolDescription,
    required this.questions,
  });

  factory SurveyQuestionsData.fromJson(Map<String, dynamic> json) => 
      _$SurveyQuestionsDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$SurveyQuestionsDataToJson(this);
}