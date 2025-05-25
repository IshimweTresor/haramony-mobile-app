import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_project/API/user.api.dart';
import 'package:my_project/models/issue.model.dart';

class IssueApiService {
  // Base URL for the API
  static const String baseUrl = 'https://village-issue-backend.vercel.app/api/issues';
  
  // Get auth headers helper
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await UserApiService.getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create a new issue
  static Future<Map<String, dynamic>> createIssue({
    required String title,
    required String description,
    required String categoryId,
    Location? location,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'title': title,
        'description': description,
        'categoryId': categoryId,
      };
      
      if (location != null) {
        body['location'] = location.toJson();
      }
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getAuthHeaders(),
        body: jsonEncode(body),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'issue': Issue.fromJson(data['data']),
          'message': 'Issue created successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create issue',
        };
      }
    } catch (e) {
      debugPrint('Error creating issue: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Get all issues
  static Future<Map<String, dynamic>> getAllIssues() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _getAuthHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<Issue> issuesList = [];
        
        for (var issueJson in data['data']) {
          try {
            final issue = Issue.fromJson(issueJson);
            issuesList.add(issue);
          } catch (e) {
            debugPrint('Error parsing issue: $e');
            // Continue with next issue if one fails to parse
          }
        }
            
        return {
          'success': true,
          'issues': issuesList,
          'count': data['count'] ?? issuesList.length,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load issues',
        };
      }
    } catch (e) {
      debugPrint('Error getting issues: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Get issue by ID
  static Future<Map<String, dynamic>> getIssueById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'issue': Issue.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get issue details',
        };
      }
    } catch (e) {
      debugPrint('Error getting issue by ID: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Update issue
  static Future<Map<String, dynamic>> updateIssue({
    required String id,
    String? title,
    String? description,
    String? categoryId,
    String? status,
    Location? location,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (categoryId != null) body['categoryId'] = categoryId;
      if (status != null) body['status'] = status;
      if (location != null) body['location'] = location.toJson();
      
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(body),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'issue': Issue.fromJson(data['data']),
          'message': 'Issue updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update issue',
        };
      }
    } catch (e) {
      debugPrint('Error updating issue: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Delete issue
  static Future<Map<String, dynamic>> deleteIssue(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Issue deleted successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete issue',
        };
      }
    } catch (e) {
      debugPrint('Error deleting issue: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Get issues by status
  static Future<Map<String, dynamic>> getIssuesByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?status=$status'),
        headers: await _getAuthHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<Issue> issuesList = [];
        
        for (var issueJson in data['data']) {
          try {
            final issue = Issue.fromJson(issueJson);
            issuesList.add(issue);
          } catch (e) {
            debugPrint('Error parsing issue: $e');
          }
        }
            
        return {
          'success': true,
          'issues': issuesList,
          'count': data['count'] ?? issuesList.length,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load issues',
        };
      }
    } catch (e) {
      debugPrint('Error getting issues by status: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Get issues by category
  static Future<Map<String, dynamic>> getIssuesByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?categoryId=$categoryId'),
        headers: await _getAuthHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<Issue> issuesList = [];
        
        for (var issueJson in data['data']) {
          try {
            final issue = Issue.fromJson(issueJson);
            issuesList.add(issue);
          } catch (e) {
            debugPrint('Error parsing issue: $e');
          }
        }
            
        return {
          'success': true,
          'issues': issuesList,
          'count': data['count'] ?? issuesList.length,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load issues',
        };
      }
    } catch (e) {
      debugPrint('Error getting issues by category: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }


// Add this new method to your IssueApiService class

// Get issues created by a specific user
static Future<Map<String, dynamic>> getIssuesByUserId(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl?userId=$userId'),
      headers: await _getAuthHeaders(),
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      final List<Issue> issuesList = [];
      
      // Check if data exists and has the expected structure
      final issuesData = data['data'] ?? [];
      
      if (issuesData is List) {
        for (var issueJson in issuesData) {
          try {
            final issue = Issue.fromJson(issueJson);
            issuesList.add(issue);
          } catch (e) {
            debugPrint('Error parsing issue: $e');
          }
        }
      }
          
      return {
        'success': true,
        'issues': issuesList,
        'count': data['count'] ?? issuesList.length,
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to load your issues',
      };
    }
  } catch (e) {
    debugPrint('Error getting user issues: $e');
    return {
      'success': false,
      'message': 'Network error. Please check your connection.',
    };
  }
}
}