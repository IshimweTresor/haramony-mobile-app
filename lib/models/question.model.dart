import 'package:json_annotation/json_annotation.dart';

part 'question.model.g.dart';

@JsonSerializable()
class Question {
  @JsonKey(name: '_id')
  final String id;
  
  final String title;
  final String description;
  final String questionText;
  final String questionType;
  final List<String> options;
  
  // These fields might be null in the API response
  final String? createdBy;
  final bool? isActive;
  
  @JsonKey(name: 'surveyTool')
  final String surveyId;
  
  // This field might be missing
  @JsonKey(defaultValue: 0)
  final int orderIndex;
  
  // These dates might not be included in the questions endpoint
  @JsonKey(includeIfNull: false)
  final DateTime? createdAt;
  
  @JsonKey(includeIfNull: false)
  final DateTime? updatedAt;
  
  @JsonKey(name: '__v', includeIfNull: false)
  final int? version;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.questionText,
    required this.questionType,
    required this.options,
    this.createdBy,
    this.isActive,
    required this.surveyId,
    required this.orderIndex,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  // Check if this question is open-ended (requires text input)
  bool get isOpenEnded => questionType == 'open';
  
  // Check if this question is closed (has predefined options)
  bool get isClosedEnded => questionType == 'closed';

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}