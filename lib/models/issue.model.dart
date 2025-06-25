import 'package:json_annotation/json_annotation.dart';
import 'user.model.dart';  // Import your existing models
import 'category.model.dart';

part 'issue.model.g.dart';

@JsonSerializable()
class Issue {
  @JsonKey(name: '_id')
  final String? id;
  
  final String title;
  final String description;
  
  @JsonKey(name: 'userId', fromJson: _parseIdField)
  final dynamic userId;
  
  @JsonKey(name: 'categoryId', fromJson: _parseIdField)
  final dynamic categoryId;
  
  final String status;
  final Location? location;
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
  
  // Populated fields from refs - use your existing model classes
  @JsonKey(includeIfNull: false)
  final User? userInfo;
  
  @JsonKey(includeIfNull: false)
  final Category? categoryInfo;

  Issue({
    this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.categoryId,
    this.status = 'Pending',
    this.location,
    this.createdAt,
    this.updatedAt,
    this.userInfo,
    this.categoryInfo,
  });

  // Helper method to handle different ID formats from API
  static dynamic _parseIdField(dynamic value) {
    return value; // Return as-is
  }
  
  // Helper method to get category ID as string
  String getCategoryIdAsString() {
    if (categoryId == null) return '';
    if (categoryId is String) return categoryId;
    if (categoryId is Map<String, dynamic>) {
      return categoryId['_id']?.toString() ?? '';
    }
    return '';
  }

  // Helper method to get user ID as string
  String getUserIdAsString() {
    if (userId == null) return '';
    if (userId is String) return userId;
    if (userId is Map<String, dynamic>) {
      return userId['_id']?.toString() ?? '';
    }
    return '';
  }

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
  Map<String, dynamic> toJson() => _$IssueToJson(this);
  
  // Create a copy with updated fields
  Issue copyWith({
    String? title,
    String? description,
    dynamic categoryId,
    String? status,
    Location? location,
  }) {
    return Issue(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userInfo: userInfo,
      categoryInfo: categoryInfo,
    );
  }
}

@JsonSerializable()
class Location {
  final String? sector;
  final String? cell;
  final String? village;
  final String? isibo;

  Location({
    this.sector,
    this.cell,
    this.village,
    this.isibo,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}