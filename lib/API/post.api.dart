import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_project/API/user.api.dart';
import 'package:my_project/models/post.model.dart';

class PostApiService {
  // Base URL for the API
  static const String baseUrl = 'https://village-issue-backend.vercel.app/api/posts';

  // Helper method to get auth headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await UserApiService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create a new post
  static Future<Map<String, dynamic>> createPost({
    String? description,
    String? image,
    String? video,
    String? title,
  }) async {
    try {
      // Ensure at least one content field is provided
      if ((description == null || description.isEmpty) && 
          image == null && video == null) {
        return {
          'success': false,
          'message': 'Post must include text, image, or video content',
        };
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'title': title,
          'description': description,
          'image': image,
          'video': video,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        final post = Post.fromJson(data);
        return {
          'success': true,
          'message': 'Post created successfully',
          'post': post,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create post',
        };
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

// Get all posts
static Future<Map<String, dynamic>> getAllPosts() async {
  try {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _getAuthHeaders(),
    );

    debugPrint('Raw posts response: ${response.body}');
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      // Debug the structure
      debugPrint('Data type: ${data.runtimeType}');
      
      List<Post> posts = [];
      
      // Handle both array and object with data property
      if (data is List) {
        posts = data.map((postJson) => Post.fromJson(postJson)).toList();
      } else if (data is Map && data.containsKey('data')) {
        // If the API returns {data: [...posts]}
        posts = (data['data'] as List).map((postJson) => Post.fromJson(postJson)).toList();
      } else {
        // Direct conversion failed, log the data structure
        debugPrint('Unexpected data structure: $data');
      }
      
      return {
        'success': true,
        'posts': posts,
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch posts',
      };
    }
  } catch (e) {
    debugPrint('Error fetching posts: $e');
    return {
      'success': false,
      'message': 'Network error. Please check your connection.',
    };
  }
}

  // Get a single post by ID
  static Future<Map<String, dynamic>> getPostById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final post = Post.fromJson(data);
        return {
          'success': true,
          'post': post,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch post',
        };
      }
    } catch (e) {
      debugPrint('Error fetching post: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Update a post
  static Future<Map<String, dynamic>> updatePost({
    required String id,
    String? title,
    String? description,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final post = Post.fromJson(data);
        return {
          'success': true,
          'message': 'Post updated successfully',
          'post': post,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update post',
        };
      }
    } catch (e) {
      debugPrint('Error updating post: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Delete a post
  static Future<Map<String, dynamic>> deletePost(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Post deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete post',
        };
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Like or unlike a post
  static Future<Map<String, dynamic>> likePost(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$id/like'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Post like action completed',
          'likes': data['likes'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to like post',
        };
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Add comment to a post
  static Future<Map<String, dynamic>> commentOnPost({
    required String postId,
    required String text,
  }) async {
    try {
      if (text.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Comment text is required',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$postId/comment'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'text': text,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Comment added successfully',
          'comment': Comment.fromJson(data['comment']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add comment',
        };
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Delete a comment
  static Future<Map<String, dynamic>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$postId/comment/$commentId'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Comment deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete comment',
        };
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Share a post
  static Future<Map<String, dynamic>> sharePost(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$id/share'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Post shared successfully',
          'shares': data['shares'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to share post',
        };
      }
    } catch (e) {
      debugPrint('Error sharing post: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Get post likes
  static Future<Map<String, dynamic>> getPostLikes(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id/likes'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'likes': data['likes'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch likes',
        };
      }
    } catch (e) {
      debugPrint('Error fetching post likes: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Get post comments
  static Future<Map<String, dynamic>> getPostComments(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id/comments'),
        headers: await _getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        List<Comment> comments = (data['comments'] as List)
            .map((commentJson) => Comment.fromJson(commentJson))
            .toList();
            
        return {
          'success': true,
          'comments': comments,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch comments',
        };
      }
    } catch (e) {
      debugPrint('Error fetching post comments: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Get post metadata counts (likes, comments, shares)
  static Future<Map<String, dynamic>> getPostCounts(String id) async {
    try {
      final likesResponse = await http.get(
        Uri.parse('$baseUrl/$id/likes/count'),
        headers: await _getAuthHeaders(),
      );
      
      final commentsResponse = await http.get(
        Uri.parse('$baseUrl/$id/comments/count'),
        headers: await _getAuthHeaders(),
      );
      
      final sharesResponse = await http.get(
        Uri.parse('$baseUrl/$id/shares/count'),
        headers: await _getAuthHeaders(),
      );

      if (likesResponse.statusCode == 200 && 
          commentsResponse.statusCode == 200 && 
          sharesResponse.statusCode == 200) {
        
        final likesData = jsonDecode(likesResponse.body);
        final commentsData = jsonDecode(commentsResponse.body);
        final sharesData = jsonDecode(sharesResponse.body);
        
        return {
          'success': true,
          'likesCount': likesData['likesCount'] ?? 0,
          'commentsCount': commentsData['commentsCount'] ?? 0,
          'sharesCount': sharesData['sharesCount'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch post counts',
        };
      }
    } catch (e) {
      debugPrint('Error fetching post counts: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}