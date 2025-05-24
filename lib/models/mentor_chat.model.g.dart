// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_chat.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorChat _$MentorChatFromJson(Map<String, dynamic> json) => MentorChat(
  id: json['_id'] as String?,
  mentor: MentorChat._mentorFromJson(json['mentor']),
  user: MentorChat._userFromJson(json['user']),
  messages: MentorChat._messagesFromJson(json['messages']),
  status: json['status'] as String? ?? 'active',
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MentorChatToJson(MentorChat instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'mentor': instance.mentor,
      'user': instance.user,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
