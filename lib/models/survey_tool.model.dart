import 'package:json_annotation/json_annotation.dart';
import 'question.model.dart';

part 'survey_tool.model.g.dart';

@JsonSerializable(explicitToJson: true)
class SurveyTool {
  @JsonKey(name: '_id')
  final String id;
  
  final String title;
  final String description;
  final String createdBy;
  final bool isActive;
  
  @JsonKey(includeIfNull: false)
  final DateTime? validFrom;
  
  @JsonKey(includeIfNull: false)
  final DateTime? validUntil;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  
  @JsonKey(name: '__v')
  final int version;
  
  final List<Question> questions;
  final bool isCurrentlyActive;

  SurveyTool({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.isActive,
    this.validFrom,
    this.validUntil,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.questions,
    required this.isCurrentlyActive,
  });

  // Helper getters
  int get questionCount => questions.length;
  bool get hasQuestions => questions.isNotEmpty;
  List<Question> get openQuestions => questions.where((q) => q.isOpenEnded).toList();
  List<Question> get closedQuestions => questions.where((q) => q.isClosedEnded).toList();
  
  // Check if survey is valid right now based on date constraints
  bool get isValidToday {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) {
      return false;
    }
    if (validUntil != null && now.isAfter(validUntil!)) {
      return false;
    }
    return isActive;
  }

  factory SurveyTool.fromJson(Map<String, dynamic> json) => _$SurveyToolFromJson(json);
  
  Map<String, dynamic> toJson() => _$SurveyToolToJson(this);
}