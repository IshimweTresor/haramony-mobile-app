// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostUser _$PostUserFromJson(Map<String, dynamic> json) => PostUser(
  id: json['_id'] as String,
  usernames: json['usernames'] as String,
  profileImage: json['profileImage'] as String?,
);

Map<String, dynamic> _$PostUserToJson(PostUser instance) => <String, dynamic>{
  '_id': instance.id,
  'usernames': instance.usernames,
  'profileImage': instance.profileImage,
};

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['_id'] as String?,
  text: json['text'] as String,
  userId: json['userId'],
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  '_id': instance.id,
  'text': instance.text,
  'userId': instance.userId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['_id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  image: json['image'] as String?,
  video: json['video'] as String?,
  userId: json['userId'],
  likes:
      (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  shares:
      (json['shares'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'image': instance.image,
  'video': instance.video,
  'userId': instance.userId,
  'likes': instance.likes,
  'comments': instance.comments,
  'shares': instance.shares,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
