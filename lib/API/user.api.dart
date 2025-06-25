import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_project/API/mentor_chat.api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.model.dart';

class UserApiService {
  // Base URL for the API
  static const String baseUrl = 'https://village-issue-backend.vercel.app/api/users';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Login user
static Future<Map<String, dynamic>> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usernames': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    
    debugPrint('API Response: ${response.body}');

    if (response.statusCode == 200) {
      try {
        // Extract token and user data
        final String token = data['token'];
        
        // Debug the user data structure
        debugPrint('User data from API: ${data['user']}');
        
        // Create user with safe parsing
        final user = User.fromJson(data['user']);

        // Save to local storage
        await _saveToLocalStorage(token, user);

        return {
          'success': true,
          'message': 'Login successful',
          'user': user,
        };
      } catch (parseError) {
        debugPrint('Error parsing response data: $parseError');
        return {
          'success': false,
          'message': 'Error processing server response',
        };
      }
    } else {
      // Handle error responses
      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
      };
    }
  } catch (e) {
    debugPrint('Login error: $e');
    return {
      'success': false,
      'message': 'Network error. Please check your connection.',
    };
  }
}


static Future<Map<String, dynamic>> register(User user) async {
  try {
    // Prepare request body - customize based on your backend requirements
    final Map<String, dynamic> requestBody = {
      'usernames': user.usernames,
      'ID_number': user.idNumber,
      'phoneNumber': user.phoneNumber,
      'password': user.password,
    };
    
    // Add location if provided
    if (user.location != null) {
      final Map<String, dynamic> locationData = {};
      
      if (user.location!.sector != null) locationData['sector'] = user.location!.sector;
      if (user.location!.cell != null) locationData['cell'] = user.location!.cell;
      if (user.location!.village != null) locationData['village'] = user.location!.village;
      if (user.location!.isibo != null) locationData['isibo'] = user.location!.isibo;
      
      if (locationData.isNotEmpty) {
        requestBody['location'] = locationData;
      }
    }

    debugPrint('Sending registration request: ${jsonEncode(requestBody)}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    final data = jsonDecode(response.body);
    debugPrint('Registration response: ${response.body}');

    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': 'Registration successful',
        'userId': data['user']?['id'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    }
  } catch (e) {
    debugPrint('Registration error: $e');
    return {
      'success': false,
      'message': 'Network error. Please check your connection.',
    };
  }
}

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(tokenKey);
  }

  // // Get current user
  // static Future<User?> getCurrentUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userData = prefs.getString(userKey);
    
  //   if (userData != null) {
  //     try {
  //       return User.fromJson(jsonDecode(userData));
  //     } catch (e) {
  //       debugPrint('Error parsing user data: $e');
  //       return null;
  //     }
  //   }
  //   return null;
  // }

  // Get auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Helper method to save user data to local storage
  static Future<void> _saveToLocalStorage(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }

// Update the getCurrentUser method to fix the ID and mentorSpecialty issues:

// Update the getCurrentUser method to work with the updated User model

static Future<User?> getCurrentUser() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    
    if (userData != null) {
      final jsonData = jsonDecode(userData);
      debugPrint('Raw stored user data: $jsonData');
      
      try {
        // Try to parse using json serialization first
        return User.fromJson(jsonData);
      } catch (parseError) {
        debugPrint('Error parsing user JSON: $parseError');
        
        // Manual parse as fallback
        String? userId = jsonData['_id'];
        
        // Try to find user ID from other sources if needed
        if (userId == null) {
          // Try to find this user in available mentors by name
          final mentors = await MentorChatApiService.getAvailableMentors();
          final username = jsonData['usernames'];
          
          for (var mentor in mentors) {
            if (mentor.usernames == username) {
              debugPrint('Found user ID in mentors list: ${mentor.id}');
              userId = mentor.id;
              break;
            }
          }
        }
        
        // Handle location data
        UserLocation? location;
        if (jsonData['location'] != null && jsonData['location'] is Map) {
          final locationData = jsonData['location'] as Map;
          location = UserLocation(
            sector: locationData['sector'],
            cell: locationData['cell'],
            village: locationData['village'],
            isibo: locationData['isibo'],
          );
        }
        
        // Create user with available data
        return User(
          id: userId,
          usernames: jsonData['usernames'] ?? '',
          idNumber: jsonData['ID_number'] ?? jsonData['idNumber'] ?? 0,
          phoneNumber: jsonData['phoneNumber'] ?? '',
          role: jsonData['role'] ?? 'user',
          mentorSpecialty: jsonData['mentorSpecialty'],
          isAvailable: jsonData['isAvailable'],
          isActive: jsonData['isActive'],
          location: location,
          profileImage: jsonData['profileImage'],
        );
      }
    }
    return null;
  } catch (e) {
    debugPrint('Error in getCurrentUser: $e');
    return null;
  }
}
}