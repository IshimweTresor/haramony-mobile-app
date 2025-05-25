import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';

part 'post.model.g.dart';

// User model for nested user info in posts
@JsonSerializable()
class PostUser {
  @JsonKey(name: '_id')
  final String id;
  
  final String usernames;
  
  @JsonKey(name: 'profileImage')
  final String? profileImage;

  PostUser({
    required this.id,
    required this.usernames,
    this.profileImage,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) => _$PostUserFromJson(json);
  
  Map<String, dynamic> toJson() => _$PostUserToJson(this);
}

@JsonSerializable()
class Comment {
  @JsonKey(name: '_id')
  final String? id;

  final String text;
  
  @JsonKey(name: 'userId')
  final dynamic userId; // Can be String or PostUser
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
  
  // Computed properties
 String get authorId {
  if (userId is String) return userId;
  if (userId is Map<String, dynamic>) return userId['_id'] ?? '';
  if (userId is PostUser) return userId.id;
  return '';
}
  String? get authorName {
  if (userId is Map<String, dynamic>) return userId['usernames'];
  if (userId is PostUser) return userId.usernames;
  return null;
}

  Comment({
    this.id,
    required this.text,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class Post {
  @JsonKey(name: '_id')
  final String? id;

  final String? title;
  final String? description;
  final String? image;
  final String? video;
  
  @JsonKey(name: 'userId')
  final dynamic _userId; // Can be String or PostUser object
  
  // Computed property to handle both String and PostUser
  PostUser? get user {
  if (_userId is PostUser) return _userId;
  if (_userId is Map<String, dynamic>) {
    try {
      return PostUser.fromJson(_userId);
    } catch (e) {
      print('Error parsing userId: $e');
      return null;
    }
  }
  return null;
}
  
  // Get author ID regardless of type
 String get userId {
  if (_userId is String) return _userId;
  if (_userId is Map<String, dynamic>) return _userId['_id'] ?? '';
  if (_userId is PostUser) return _userId.id;
  return '';
}
  
  // Get author name if available
 String? get authorName {
  if (_userId is Map<String, dynamic>) return _userId['usernames'];
  if (_userId is PostUser) return _userId.usernames;
  return null;
}
  
  @JsonKey(defaultValue: [])
  final List<String> likes;
  
  @JsonKey(defaultValue: [])
  final List<Comment> comments;
  
  @JsonKey(defaultValue: [])
  final List<String> shares;
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  Post({
    this.id,
    this.title,
    this.description,
    this.image,
    this.video,
    required dynamic userId,
    this.likes = const [],
    this.comments = const [],
    this.shares = const [],
    this.createdAt,
    this.updatedAt,
  }) : _userId = userId;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
  
  // Validation similar to backend
  bool isValid() {
    return description != null || image != null || video != null;
  }
  
  @override
  String toString() {
    final author = authorName ?? 'User ID: $userId';
    return 'Post(id: $id, author: $author, description: ${description?.substring(0, math.min(20, description?.length ?? 0))}..., '
           'likes: ${likes.length}, comments: ${comments.length})';
  }
}