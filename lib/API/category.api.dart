import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:my_project/API/user.api.dart';
import 'package:my_project/models/category.model.dart';

class CategoryApiService {
  // Base URL for the API
  static const String baseUrl = 'https://village-issue-backend.vercel.app/api/categories';
  
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

  // Create a new category
  static Future<Map<String, dynamic>> createCategory({
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'name': name,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'category': Category.fromJson(data),
          'message': 'Category created successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create category',
        };
      }
    } catch (e) {
      debugPrint('Error creating category: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Get all categories
  static Future<Map<String, dynamic>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _getAuthHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<Category> categoriesList = [];
        
        for (var categoryJson in data) {
          try {
            final category = Category.fromJson(categoryJson);
            categoriesList.add(category);
          } catch (e) {
            debugPrint('Error parsing category: $e');
            // Continue with next category if one fails to parse
          }
        }
            
        return {
          'success': true,
          'categories': categoriesList,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load categories',
        };
      }
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Get category by ID
  static Future<Map<String, dynamic>> getCategoryById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'category': Category.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get category details',
        };
      }
    } catch (e) {
      debugPrint('Error getting category by ID: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Update category
  static Future<Map<String, dynamic>> updateCategory({
    required String id,
    required String name,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'name': name,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'category': Category.fromJson(data),
          'message': 'Category updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update category',
        };
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Delete category
  static Future<Map<String, dynamic>> deleteCategory(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Category deleted successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete category',
        };
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}