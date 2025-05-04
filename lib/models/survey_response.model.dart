import 'package:json_annotation/json_annotation.dart';
import 'survey_tool.model.dart';

part 'survey_response.model.g.dart';

@JsonSerializable(explicitToJson: true)
class SurveyResponse {
  final bool success;
  final List<SurveyTool> data;

  SurveyResponse({
    required this.success,
    required this.data,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) => _$SurveyResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$SurveyResponseToJson(this);
}