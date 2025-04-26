import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

  // Register user
  static Future<Map<String, dynamic>> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registration successful',
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

  // Get current user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    
    if (userData != null) {
      try {
        return User.fromJson(jsonDecode(userData));
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

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
}