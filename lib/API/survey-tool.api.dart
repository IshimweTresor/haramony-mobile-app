import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/survey_response.model.dart';
import '../models/survey_tool.model.dart';
import '../models/survey_answer.model.dart';
import 'user.api.dart';
import '../models/survey_questions_response.model.dart';

class SurveyApiService {
  // Base URL for the API
  static const String baseUrl = 'https://village-issue-backend.vercel.app/api/survey-tool/tools';
  
  // Get all survey tools
  static Future<List<SurveyTool>> getAllSurveys() async {
    try {
      // Get auth token
      final token = await UserApiService.getAuthToken();
      
      if (token == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final surveyResponse = SurveyResponse.fromJson(data);
        return surveyResponse.data;
      } else {
        debugPrint('Failed to load surveys: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching surveys: $e');
      return [];
    }
  }
  
  // Get survey tool by ID
  static Future<SurveyTool?> getSurveyById(String id) async {
    try {
      // Get auth token
      final token = await UserApiService.getAuthToken();
      
      if (token == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final surveyTool = SurveyTool.fromJson(data['data']);
        return surveyTool;
      } else {
        debugPrint('Failed to load survey: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching survey: $e');
      return null;
    }
  }
  

// Update the submitQuestionResponse method

static Future<Map<String, dynamic>> submitQuestionResponse(String questionId, SurveyAnswer answer) async {
  try {
    // Get auth token
    final token = await UserApiService.getAuthToken();
    
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    // Get current user info
    final user = await UserApiService.getCurrentUser();
    if (user == null) {
      throw Exception('User information not available');
    }
    
    // Build the request payload
    final Map<String, dynamic> payload = {
      'userId': user.usernames,
    };
    
    // Add response text (use either textAnswer or selectedOption)
     if (answer.response != null) {
      payload['response'] = answer.response;
    }
    
    // Add location data (required by the API)
    payload['location'] = {
      'province': answer.location.province,
      'district': answer.location.district,
      'sector': answer.location.sector,
    };
    
    debugPrint('Submitting payload: ${jsonEncode(payload)}');
    
    final response = await http.post(
      Uri.parse('https://village-issue-backend.vercel.app/api/survey-tool/questions/$questionId/responses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    debugPrint('Response submission status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'message': 'Response submitted successfully',
        'data': data,
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to submit response',
      };
    }
  } catch (e) {
    debugPrint('Error submitting response: $e');
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}

// Submit all survey answers at once
static Future<Map<String, dynamic>> submitSurveyResponses(String surveyId, List<SurveyAnswer> answers) async {
  try {
    // Submit each question response separately
    List<Map<String, dynamic>> results = [];
    
    for (var answer in answers) {
      final result = await submitQuestionResponse(answer.questionId, answer);
      results.add(result);
      
      // If any submission fails, return the error
      if (!result['success']) {
        return result;
      }
    }
    
    // All submissions succeeded
    return {
      'success': true,
      'message': 'All responses submitted successfully',
      'results': results,
    };
  } catch (e) {
    debugPrint('Error submitting survey responses: $e');
    return {
      'success': false,
      'message': 'Error submitting survey: $e',
    };
  }
}


// Get questions for a specific survey tool
static Future<SurveyQuestionsData?> getSurveyQuestions(String surveyId) async {
  try {
    // Get auth token
    final token = await UserApiService.getAuthToken();
    
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/$surveyId/questions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Debug the response data
      debugPrint('Survey questions response: ${response.body}');
      
      try {
        final questionsResponse = SurveyQuestionsResponse.fromJson(data);
        return questionsResponse.data;
      } catch (e) {
        debugPrint('Error parsing survey questions: $e');
        
        // Try a manual approach to debug the specific fields causing issues
        final toolTitle = data['data']['toolTitle'] as String;
        final toolDescription = data['data']['toolDescription'] as String;
        final questions = data['data']['questions'] as List;
        
        debugPrint('Tool Title: $toolTitle');
        debugPrint('Tool Description: $toolDescription');
        debugPrint('Questions count: ${questions.length}');
        
        if (questions.isNotEmpty) {
          debugPrint('First question fields: ${questions.first.keys.join(', ')}');
        }
        
        return null;
      }
    } else {
      debugPrint('Failed to load survey questions: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Error fetching survey questions: $e');
    return null;
  }
}
}