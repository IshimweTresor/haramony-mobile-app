import 'package:json_annotation/json_annotation.dart';

part 'mentor_chat.model.g.dart';

@JsonSerializable(explicitToJson: true)
class MentorChat {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(fromJson: _mentorFromJson)
  final String mentor;
  
  @JsonKey(fromJson: _userFromJson)
  final String user;
  
  @JsonKey(fromJson: _messagesFromJson)
  final List<ChatMessage> messages;
  
  final String status;
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  MentorChat({
    this.id,
    required this.mentor,
    required this.user,
    required this.messages,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory MentorChat.fromJson(Map<String, dynamic> json) {
    try {
      return _$MentorChatFromJson(json);
    } catch (e) {
      print('Error in MentorChat.fromJson: $e');
      return MentorChat(
        id: json['_id'],
        mentor: _mentorFromJson(json['mentor']),
        user: _userFromJson(json['user']),
        messages: _messagesFromJson(json['messages']),
        status: json['status'] ?? 'active',
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );
    }
  }
  
  Map<String, dynamic> toJson() => _$MentorChatToJson(this);
  
  // Custom converter for mentor field that can be either a String or an Object
  static String _mentorFromJson(dynamic mentor) {
    if (mentor is String) return mentor;
    if (mentor is Map<String, dynamic>) return mentor['_id']?.toString() ?? '';
    return '';
  }
  
  // Custom converter for user field that can be either a String or an Object
  static String _userFromJson(dynamic user) {
    if (user is String) return user;
    if (user is Map<String, dynamic>) return user['_id']?.toString() ?? '';
    return '';
  }
  
  // Custom converter for messages
  static List<ChatMessage> _messagesFromJson(dynamic messages) {
    if (messages is List) {
      return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
    }
    return [];
  }
}

class ChatMessage {
  final String id;
  final String sender;
  final String? senderName;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    this.senderName,
    required this.sender,
    required this.content,
    this.isRead = false,
    this.createdAt,
  });

    factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Extract sender ID and name based on the format
    String senderId;
    String? senderName;
    
    if (json['sender'] is Map) {
      senderId = json['sender']['_id'] ?? '';
      senderName = json['sender']['usernames'];
    } else {
      senderId = json['sender'] ?? '';
    }
    
    return ChatMessage(
      id: json['_id'] ?? '',
      sender: senderId,
      senderName: senderName,
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}