import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_project/API/user.api.dart';
import '../models/mentor_chat.model.dart';
import '../models/user.model.dart';

class MentorChatApiService {
  // Base URL for the API
  static const String baseUrl = 'https://village-issue-backend.vercel.app/api/mentor-chat';

  // Get authorization headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await UserApiService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

// Get available mentors
static Future<List<User>> getAvailableMentors() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/mentors'),
      headers: await _getAuthHeaders(),
    );

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      final List<dynamic> mentorsList = data['data'];
      // Log the raw mentor data to see what's coming from the API
      debugPrint('Raw mentors data: ${mentorsList.toString()}');
      
      // Safely convert to User models with error handling
      List<User> users = [];
      for (var mentorJson in mentorsList) {
        try {
          // Make sure required fields exist
          if (mentorJson['usernames'] != null) {
            // Provide safe defaults for potentially null values
            users.add(User(
              id: mentorJson['_id'], // Capture the MongoDB ObjectId
              usernames: mentorJson['usernames'],
              idNumber: mentorJson['ID_number'] ?? 0,
              phoneNumber: mentorJson['phoneNumber'] ?? '',
              mentorSpecialty: mentorJson['mentorSpecialty'],
            ));
          }
        } catch (e) {
          debugPrint('Error processing mentor: $e for data: $mentorJson');
          // Continue to next mentor instead of failing the whole list
        }
      }
      return users;
    } else {
      throw Exception(data['message'] ?? 'Failed to get available mentors');
    }
  } catch (e) {
    debugPrint('Error getting available mentors: $e');
    throw Exception('Network error. Please check your connection.');
  }
}
  // Start a chat with a mentor
  static Future<MentorChat> startChat(String mentorId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/start'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'mentorId': mentorId,
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return MentorChat.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to start chat');
      }
    } catch (e) {
      debugPrint('Error starting chat: $e');
      throw Exception('Network error. Please check your connection.');
    }
  }

  // Send message in existing chat
  static Future<Map<String, dynamic>> sendMessage(String chatId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/message'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'chatId': chatId,
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        print('Send message response: $data');
        return {
          'message': ChatMessage.fromJson(data['data']['message']),
          'unreadCount': data['data']['unreadCount'],
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Network error. Please check your connection.');
    }
  }

  // Get chat history
  static Future<MentorChat> getChatHistory(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        print('Chat history response: $data');
        return MentorChat.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get chat history');
      }
    } catch (e) {
      debugPrint('Error getting chat history: $e');
      throw Exception('Network error. Please check your connection.');
    }
  }

  // Mark messages as read
  static Future<MentorChat> markMessagesAsRead(String chatId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chats/$chatId/read'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return MentorChat.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to mark messages as read');
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      throw Exception('Network error. Please check your connection.');
    }
  }

  // Get unread message count
  static Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/unread'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data['data']['unreadCount'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get unread count');
      }
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      throw Exception('Network error. Please check your connection.');
    }
  }

// Replace the getMentorChats method with this improved version:

static Future<List<Map<String, dynamic>>> getMentorChats() async {
  try {
    debugPrint('Fetching mentor chats...');
    final response = await http.get(
      Uri.parse('$baseUrl/mentor/chats'),
      headers: await _getAuthHeaders(),
    );

    final data = jsonDecode(response.body);
    debugPrint('getMentorChats raw response: $data');
    
    if (response.statusCode == 200) {
      print('getMentorChats successful, data: $data');
      final List<dynamic> chatsList = data['data'];
      debugPrint('Mentor chats list length: ${chatsList.length}');
      
      List<Map<String, dynamic>> result = [];
      
      for (var chatData in chatsList) {
        try {
          debugPrint('Processing mentor chat: $chatData');
          result.add({
            'chat': MentorChat.fromJson(chatData),
            'unreadCount': chatData['unreadCount'] ?? 0,
          });
        } catch (e) {
          debugPrint('Error processing mentor chat: $e for data: $chatData');
          // Continue to next chat
        }
      }
      
      return result;
    } else {
      throw Exception(data['message'] ?? 'Failed to get mentor chats');
    }
  } catch (e) {
    debugPrint('Error getting mentor chats: $e');
    throw Exception('Network error. Please check your connection.');
  }
}
// In the getUserChats method:
static Future<List<Map<String, dynamic>>> getUserChats() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user/chats'),
      headers: await _getAuthHeaders(),
    );

    final data = jsonDecode(response.body);
    debugPrint('getUserChats raw response: $data');
    
    if (response.statusCode == 200) {
      print('getUserChats successful, data: $data');
      print('User chats response: $data');
      final List<dynamic> chatsList = data['data'];
      debugPrint('Chats list length: ${chatsList.length}');
      print('User chats list: $chatsList');
      
      List<Map<String, dynamic>> result = [];
      
      for (var chatData in chatsList) {
        try {
          debugPrint('Processing chat: $chatData');
          result.add({
            'chat': MentorChat.fromJson(chatData),
            'unreadCount': chatData['unreadCount'] ?? 0,
          });
        } catch (e) {
          debugPrint('Error processing chat: $e for data: $chatData');
          // Continue to next chat
        }
      }
      
      return result;
    } else {
      throw Exception(data['message'] ?? 'Failed to get user chats');
    }
  } catch (e) {
    debugPrint('Error getting user chats: $e');
    throw Exception('Network error. Please check your connection.');
  }
}
}