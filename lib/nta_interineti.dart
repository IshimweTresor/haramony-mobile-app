import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:my_project/navigation_bar.dart';
import 'package:my_project/API/post.api.dart';
import 'package:my_project/models/post.model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class NtaInterineti extends StatefulWidget {
  @override
  State<NtaInterineti> createState() => _NtaInterinetiState();
}

// Helper function to safely truncate strings
String _safeTruncate(String? text, int length) {
  if (text == null || text.isEmpty) return 'Unknown';
  if (text.length <= length) return text;
  return '${text.substring(0, length)}...';
}

String _safeSubstring(String? text, int start, int end) {
  if (text == null || text.isEmpty) return '';
  if (start < 0) start = 0;
  if (end > text.length) end = text.length;
  if (start >= text.length || start >= end) return '';
  return text.substring(start, end);
}

class _NtaInterinetiState extends State<NtaInterineti> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  List<Post> posts = [];
  
  // Twitter-style colors
  final Color _twitterBlue = Color(0xFF1DA1F2);
  final Color _twitterBackground = Color(0xFF15202B);  // Twitter dark mode background
  final Color _twitterCardBackground = Color(0xFF192734);
  final Color _twitterTextColor = Colors.white;
  final Color _twitterSecondaryTextColor = Color(0xFF8899A6);


  // Show post options menu
void _showPostOptions(Post post) {
  showModalBottomSheet(
    context: context,
    backgroundColor: _twitterCardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pull handle
        Container(
          width: 40,
          height: 5,
          margin: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        
        // Edit option
        ListTile(
          leading: Icon(Icons.edit, color: _twitterTextColor),
          title: Text('Edit post', style: TextStyle(color: _twitterTextColor)),
          onTap: () {
            Navigator.pop(context);
            _editPost(post);
          },
        ),
        
        // Delete option
        ListTile(
          leading: Icon(Icons.delete_outline, color: Colors.redAccent),
          title: Text('Delete post', style: TextStyle(color: Colors.redAccent)),
          onTap: () {
            Navigator.pop(context);
            _confirmDelete(post);
          },
        ),
        
        Divider(color: Colors.grey[800], height: 1),
        
        // Bookmark
        ListTile(
          leading: Icon(Icons.bookmark_border, color: _twitterTextColor),
          title: Text('Bookmark', style: TextStyle(color: _twitterTextColor)),
          onTap: () {
            Navigator.pop(context);
            _showSnackBar('Post bookmarked');
          },
        ),
        
        // Report
        ListTile(
          leading: Icon(Icons.flag_outlined, color: _twitterTextColor),
          title: Text('Report post', style: TextStyle(color: _twitterTextColor)),
          onTap: () {
            Navigator.pop(context);
            _showSnackBar('Post reported');
          },
        ),
        
        SizedBox(height: 16),
      ],
    ),
  );
}

// Edit post
void _editPost(Post post) {
  final controller = TextEditingController(text: post.description);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: _twitterCardBackground,
      title: Text('Edit post', style: TextStyle(color: _twitterTextColor)),
      content: TextField(
        controller: controller,
        style: TextStyle(color: _twitterTextColor),
        maxLines: 5,
        decoration: InputDecoration(
          hintText: "What's happening?",
          hintStyle: TextStyle(color: _twitterSecondaryTextColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _twitterSecondaryTextColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _twitterSecondaryTextColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _twitterBlue),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: _twitterSecondaryTextColor)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (controller.text.trim().isEmpty) {
              _showSnackBar('Post cannot be empty');
              return;
            }
            
            Navigator.pop(context);
            _showSnackBar('Updating post...');
            
            try {
              // Call your API here
              // For example: await PostApiService.updatePost(post.id!, controller.text);
              
              // For now, just show a success message
              _showSnackBar('Post updated successfully');
              
              // In a real app, refresh the post list
              // _loadPosts();
            } catch (e) {
              _showSnackBar('Error updating post: $e');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _twitterBlue,
            foregroundColor: Colors.white,
          ),
          child: Text('Save'),
        ),
      ],
    ),
  );
}

// Confirm delete
void _confirmDelete(Post post) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: _twitterCardBackground,
      title: Text(
        'Delete post?',
        style: TextStyle(color: _twitterTextColor),
      ),
      content: Text(
        'This cant be undone and the post will be removed from your profile.',
        style: TextStyle(color: _twitterSecondaryTextColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: _twitterSecondaryTextColor)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _deletePost(post);
          },
          child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );
}

// Delete post
void _deletePost(Post post) {
  _showSnackBar('Deleting post...');
  
  try {
    // In a real app, call your API:
    // await PostApiService.deletePost(post.id!);
    
    // For now, just show a success message and optimistically remove from UI
    setState(() {
      posts.removeWhere((p) => p.id == post.id);
    });
    
    _showSnackBar('Post deleted successfully');
    
  } catch (e) {
    _showSnackBar('Error deleting post: $e');
  }
}

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Load posts from API
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await PostApiService.getAllPosts();
      
      if (response['success']) {
        setState(() {
          posts = response['posts'] as List<Post>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load posts';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Select image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Take photo with camera
  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Upload image to server and get URL
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('https://village-issue-backend.vercel.app/api/upload');
      
      // Create a multipart request
      var request = http.MultipartRequest('POST', uri);

      // Attach file
      var pic = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(pic);
      
      // Send request
      var response = await request.send();
      
      // Check response
      if (response.statusCode == 200) {
        // If successful, parse response
        final respStr = await response.stream.bytesToString();
        final jsonData = jsonDecode(respStr);
        return jsonData['imageUrl'];
      } else {
        debugPrint('Image upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Format datetime for display (Twitter style)
  String _formatTwitterDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return DateFormat('MMM d, y').format(date); // Jan 1, 2023
    } else if (difference.inDays > 7) {
      return DateFormat('MMM d').format(date); // Jan 1
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d'; // 3d
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h'; // 5h
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m'; // 30m
    } else {
      return 'now'; // now
    }
  }

  // Send new post to API
  Future<void> _sendPost() async {
    // Validate inputs
    if (_textController.text.isEmpty && _image == null) {
      _showSnackBar("Post must have text or image");
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // If we have an image, upload it first
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
        if (imageUrl == null) {
          setState(() {
            _isSending = false;
          });
          _showSnackBar("Failed to upload image. Please try again.");
          return;
        }
      }

      // Create post with API
      final response = await PostApiService.createPost(
        description: _textController.text,
        image: imageUrl,
      );

      setState(() {
        _isSending = false;
      });

      if (response['success']) {
        // Clear form
        _textController.clear();
        setState(() {
          _image = null;
        });
        
        // Show success and refresh posts
        _showSnackBar("Post created successfully!");
        _loadPosts();
      } else {
        _showSnackBar(response['message'] ?? "Failed to create post");
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      _showSnackBar("Error: $e");
    }
  }

  // Custom SnackBar with Twitter style
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _twitterCardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.all(8),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Handle navigation bar taps
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/nta_interineti');
        break;
      case 2:
        Navigator.pushNamed(context, '/forum');
        break;
      case 3:
        Navigator.pushNamed(context, '/report');
        break;
    }
  }

  // Like post with API (with optimistic UI update for Twitter-like experience)
  Future<void> _likePost(String postId) async {
    HapticFeedback.lightImpact(); // Haptic feedback like Twitter
    
    // Find the post
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex < 0) return;
    
    final post = posts[postIndex];
    
    // Optimistically update the UI
    setState(() {
      List<String> updatedLikes = List.from(post.likes);
      if (updatedLikes.contains(post.userId)) {
        updatedLikes.remove(post.userId);
      } else {
        updatedLikes.add(post.userId);
      }
      
      posts[postIndex] = Post(
        id: post.id,
        userId: post.userId,
        title: post.title,
        description: post.description,
        image: post.image,
        video: post.video,
        likes: updatedLikes,
        comments: post.comments,
        shares: post.shares,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );
    });
    
    // Make the actual API call
    try {
      await PostApiService.likePost(postId);
      // We don't reload the posts immediately to avoid flickering
      // The next pull-to-refresh will sync the data
    } catch (e) {
      _showSnackBar("Error: $e");
      _loadPosts(); // Reload on error to ensure correct state
    }
  }

  // Add comment with API
  Future<void> _addComment(String postId, String text) async {
    if (text.trim().isEmpty) return;

    try {
      final response = await PostApiService.commentOnPost(
        postId: postId,
        text: text,
      );

      if (response['success']) {
        HapticFeedback.mediumImpact(); // Haptic feedback for successful comment
        // Refresh posts to show new comment
        _loadPosts();
      } else {
        _showSnackBar(response['message'] ?? 'Failed to add comment');
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // Share post with API
  Future<void> _sharePost(String postId) async {
    // Show Twitter-style share sheet
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: _twitterCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pull handle
            Container(
              width: 40,
              height: 5,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _twitterBlue.withOpacity(0.2),
                child: Icon(Icons.repeat, color: _twitterBlue),
              ),
              title: Text('Repost', style: TextStyle(color: _twitterTextColor)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final response = await PostApiService.sharePost(postId);
                  if (response['success']) {
                    _showSnackBar("Post reshared!");
                    _loadPosts();
                  } else {
                    _showSnackBar(response['message'] ?? 'Failed to share post');
                  }
                } catch (e) {
                  _showSnackBar("Error: $e");
                }
              },
            ),
            
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.2),
                child: Icon(Icons.bookmark_outline, color: Colors.green),
              ),
              title: Text('Bookmark', style: TextStyle(color: _twitterTextColor)),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("Added to bookmarks");
              },
            ),
            
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withOpacity(0.2),
                child: Icon(Icons.share, color: Colors.purple),
              ),
              title: Text('Share via...', style: TextStyle(color: _twitterTextColor)),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("Share option selected");
              },
            ),
            
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Show Twitter-style compose tweet screen
  void _showComposeScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _twitterBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                children: [
                  // Header with cancel and tweet buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _textController.clear();
                            setModalState(() => _image = null);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: _twitterBlue),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isSending
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _sendPost();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _twitterBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                          ),
                          child: _isSending
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text('Post'),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.grey[800], height: 1),

                  // Compose area
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[400],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: "What's happening?",
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: _twitterTextColor,
                                  fontSize: 18,
                                ),
                                autofocus: true,
                              ),
                            ),
                          ],
                        ),
                        
                        // Image preview
                        if (_image != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(_image!),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setModalState(() => _image = null);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bottom media options bar
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _twitterBackground,
                      border: Border(
                        top: BorderSide(color: Colors.grey[800]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.photo_library_outlined, color: _twitterBlue),
                          onPressed: () {
                            _pickImage().then((_) {
                              setModalState(() {});
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt_outlined, color: _twitterBlue),
                          onPressed: () {
                            _takePhoto().then((_) {
                              setModalState(() {});
                            });
                          },
                        ),
                        Spacer(),
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            border: Border.all(color: _textController.text.isEmpty ? Colors.grey[800]! : _twitterBlue),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${280 - _textController.text.length}',
                              style: TextStyle(
                                color: _textController.text.isEmpty ? Colors.grey[800] : _twitterBlue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _twitterBackground,
      appBar: AppBar(
        title: Text(
          "Itumanaho",
          style: GoogleFonts.poppins(
            color: _twitterTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _twitterBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome, color: _twitterBlue),
            onPressed: () => _showSnackBar("For You timeline"),
          ),
        ],
      ),
      body: _isLoading && posts.isEmpty
          ? Center(child: CircularProgressIndicator(color: _twitterBlue))
          : _errorMessage != null
              ? _buildErrorState()
              : posts.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: _twitterBlue,
                      onRefresh: _loadPosts,
                      child: ListView.separated(
                        itemCount: posts.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[800],
                          height: 1,
                        ),
                        itemBuilder: (context, index) => _buildTwitterPost(posts[index]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showComposeScreen,
        backgroundColor: _twitterBlue,
        child: Icon(Icons.add, color: Colors.white),
        elevation: 2,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  // Error state widget
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.redAccent,
            ),
            SizedBox(height: 16),
            Text(
              'Could not load posts',
              style: TextStyle(
                color: _twitterTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred',
              style: TextStyle(
                color: _twitterSecondaryTextColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: _twitterBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_quote,
              size: 70,
              color: _twitterBlue,
            ),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                color: _twitterTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts with the community!',
              style: TextStyle(
                color: _twitterSecondaryTextColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showComposeScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: _twitterBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Create First Post'),
            ),
          ],
        ),
      ),
    );
  }

  // Twitter post item
  Widget _buildTwitterPost(Post post) {
    final bool isLiked = post.likes.contains(post.userId);
    
    // Get first letter of username for avatar
    String avatarLetter = (post.authorName?.isNotEmpty == true) 
        ? post.authorName![0].toUpperCase() 
        : 'U';
    
    return InkWell(
      onTap: () => _showPostDetail(post),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture
            CircleAvatar(
              backgroundColor: _twitterBlue.withOpacity(0.2),
              child: Text(
                avatarLetter,
                style: TextStyle(
                  color: _twitterBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info row
                  Row(
                    children: [
                      // Username
                      Text(
                        post.authorName ?? 'User ${_safeTruncate(post.userId, 5)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _twitterTextColor,
                        ),
                      ),
                      
                      // Handle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          '@${_safeSubstring(post.userId, 0, 4)}',
                          style: TextStyle(
                            color: _twitterSecondaryTextColor,
                          ),
                        ),
                      ),
                      
                      // Time
                      Text(
                        '· ${_formatTwitterDate(post.createdAt)}',
                        style: TextStyle(
                          color: _twitterSecondaryTextColor,
                        ),
                      ),
                      
                      Spacer(),
                      
                      // More options
                      // Replace the Icon with this IconButton
IconButton(
  icon: Icon(
    Icons.more_horiz,
    color: _twitterSecondaryTextColor,
    size: 16,
  ),
  onPressed: () => _showPostOptions(post),
  padding: EdgeInsets.zero,
  constraints: BoxConstraints.tightFor(width: 32, height: 32),
  visualDensity: VisualDensity.compact,
),
                    ],
                  ),
                  
                  SizedBox(height: 4),
                  
                  // Post text
                  if (post.description != null && post.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        post.description!,
                        style: TextStyle(
                          color: _twitterTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                  // Post image
                  if (post.image != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          post.image!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey[800],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: _twitterSecondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Comment button
                      _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        count: post.comments.length,
                        onTap: () => _showAllComments(post),
                      ),
                      
                      // Repost button
                      _buildActionButton(
                        icon: Icons.repeat,
                        count: post.shares.length,
                        onTap: () => _sharePost(post.id!),
                      ),
                      
                      // Like button
                      _buildActionButton(
                        icon: isLiked ? Icons.favorite : Icons.favorite_outline,
                        count: post.likes.length,
                        color: isLiked ? Colors.pink : null,
                        onTap: () => _likePost(post.id!),
                      ),
                      
                      // Share button
                      IconButton(
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.share_outlined,
                          color: _twitterSecondaryTextColor,
                          size: 18,
                        ),
                        onPressed: () => _sharePost(post.id!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Twitter-style action button
  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? _twitterSecondaryTextColor,
          ),
          SizedBox(width: 4),
          count > 0
              ? Text(
                  count.toString(),
                  style: TextStyle(
                    color: color ?? _twitterSecondaryTextColor,
                    fontSize: 14,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  // Show post detail screen
  void _showPostDetail(Post post) {
    final bool isLiked = post.likes.contains(post.userId);
    
    // Get first letter of username for avatar
    String avatarLetter = (post.authorName?.isNotEmpty == true) 
        ? post.authorName![0].toUpperCase() 
        : 'U';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: _twitterBackground,
          appBar: AppBar(
            backgroundColor: _twitterBackground,
            elevation: 0,
            title: Text(
              'Post',
              style: TextStyle(color: _twitterTextColor),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: _twitterTextColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Main post
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _twitterBlue.withOpacity(0.2),
                                radius: 24,
                                child: Text(
                                  avatarLetter,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: _twitterBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.authorName ?? 'User ${_safeTruncate(post.userId, 5)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _twitterTextColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '@${_safeSubstring(post.userId, 0, 4)}',
                                    style: TextStyle(
                                      color: _twitterSecondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Post text in larger font
                          if (post.description != null && post.description!.isNotEmpty)
                            Text(
                              post.description!,
                              style: TextStyle(
                                color: _twitterTextColor,
                                fontSize: 22,
                              ),
                            ),
                            
                          // Post image larger
                          if (post.image != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  post.image!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 250,
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: _twitterSecondaryTextColor,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                          SizedBox(height: 16),
                          
                          // Time
                          Text(
                            post.createdAt != null 
                              ? DateFormat('h:mm a · MMM d, yyyy').format(post.createdAt!) 
                              : '',
                            style: TextStyle(
                              color: _twitterSecondaryTextColor,
                            ),
                          ),
                          
                          Divider(color: Colors.grey[800], height: 24),
                          
                          // Stats
                          if (post.likes.isNotEmpty || post.comments.isNotEmpty || post.shares.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Wrap(
                                spacing: 16,
                                children: [
                                  if (post.likes.isNotEmpty)
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${post.likes.length} ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _twitterTextColor,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Likes',
                                            style: TextStyle(
                                              color: _twitterSecondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (post.comments.isNotEmpty)
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${post.comments.length} ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _twitterTextColor,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Comments',
                                            style: TextStyle(
                                              color: _twitterSecondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (post.shares.isNotEmpty)
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${post.shares.length} ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _twitterTextColor,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Reposts',
                                            style: TextStyle(
                                              color: _twitterSecondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                          Divider(color: Colors.grey[800], height: 24),
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Comment button
                              IconButton(
                                icon: Icon(
                                  Icons.chat_bubble_outline,
                                  color: _twitterSecondaryTextColor,
                                ),
                                onPressed: () => _showAllComments(post),
                              ),
                              
                              // Repost button
                              IconButton(
                                icon: Icon(
                                  Icons.repeat,
                                  color: _twitterSecondaryTextColor,
                                ),
                                onPressed: () => _sharePost(post.id!),
                              ),
                              
                              // Like button
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_outline,
                                  color: isLiked ? Colors.pink : _twitterSecondaryTextColor,
                                ),
                                onPressed: () {
                                  _likePost(post.id!);
                                  Navigator.pop(context);
                                  _showPostDetail(post);
                                },
                              ),
                              
                              // Share button
                              IconButton(
                                icon: Icon(
                                  Icons.share_outlined,
                                  color: _twitterSecondaryTextColor,
                                ),
                                onPressed: () => _sharePost(post.id!),
                              ),
                            ],
                          ),
                          
                          Divider(color: Colors.grey[800], height: 24),
                        ],
                      ),
                    ),
                    
                    // Comments section header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        post.comments.isEmpty 
                            ? 'No comments yet' 
                            : 'Comments',
                        style: TextStyle(
                          color: _twitterTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    
                    // Comments
                    ...post.comments.map((comment) {
                      String commentAvatarLetter = (comment.authorName?.isNotEmpty == true) 
                          ? comment.authorName![0].toUpperCase() 
                          : 'U';
                          
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: _twitterBlue.withOpacity(0.1),
                              child: Text(
                                commentAvatarLetter,
                                style: TextStyle(
                                  color: _twitterBlue,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.authorName ?? 'User ${_safeTruncate(comment.authorId, 4)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _twitterTextColor,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '@${_safeSubstring(comment.authorId, 0, 4)}',
                                        style: TextStyle(
                                          color: _twitterSecondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '· ${_formatTwitterDate(comment.createdAt)}',
                                        style: TextStyle(
                                          color: _twitterSecondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    comment.text,
                                    style: TextStyle(
                                      color: _twitterTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  
                                  // Comment action buttons
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        color: _twitterSecondaryTextColor,
                                        size: 14,
                                      ),
                                      SizedBox(width: 16),
                                      Icon(
                                        Icons.favorite_outline,
                                        color: _twitterSecondaryTextColor,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              // Comment input at bottom
              Container(
                padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 8 + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: _twitterBackground,
                  border: Border(
                    top: BorderSide(color: Colors.grey[800]!),
                  ),
                ),
                child: _buildCommentInputRow(post.id!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build comment input row with avatar
  Widget _buildCommentInputRow(String postId) {
    final commentController = TextEditingController();
    
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: _twitterBlue.withOpacity(0.2),
          child: Icon(Icons.person, color: _twitterBlue),
        ),
        SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: commentController,
            style: TextStyle(color: _twitterTextColor),
            decoration: InputDecoration(
              hintText: 'Post your reply',
              hintStyle: TextStyle(color: _twitterSecondaryTextColor),
              border: InputBorder.none,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (commentController.text.trim().isNotEmpty) {
              _addComment(postId, commentController.text);
              commentController.clear();
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: _twitterBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          child: Text('Reply'),
        ),
      ],
    );
  }

  void _showAllComments(Post post) {
    // Fix: Create a single controller for the TextField
    final TextEditingController commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _twitterBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Pull handle
            Container(
              width: 40,
              height: 5,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Comments',
                    style: TextStyle(
                      color: _twitterTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: _twitterTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Divider(color: Colors.grey[800], height: 1),
            
            // Comments list
            Expanded(
              child: post.comments.isEmpty
                  ? Center(
                      child: Text(
                        'No comments yet',
                        style: TextStyle(color: _twitterSecondaryTextColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];
                        String commentAvatarLetter = (comment.authorName?.isNotEmpty == true) 
                            ? comment.authorName![0].toUpperCase() 
                            : 'U';
                        
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _twitterBlue.withOpacity(0.2),
                                child: Text(
                                  commentAvatarLetter,
                                  style: TextStyle(color: _twitterBlue),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    comment.authorName ?? 'User ${_safeTruncate(comment.authorId, 4)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _twitterTextColor,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '@${comment.authorId.substring(0, 4)} · ${_formatTwitterDate(comment.createdAt)}',
                                    style: TextStyle(
                                      color: _twitterSecondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  comment.text,
                                  style: TextStyle(color: _twitterTextColor),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            Divider(color: Colors.grey[800], height: 1),
                          ],
                        );
                      },
                    ),
            ),
            
            // Comment input field
            Container(
              padding: EdgeInsets.fromLTRB(
                16, 8, 16, 8 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: _twitterBackground,
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _twitterBlue.withOpacity(0.2),
                    child: Icon(Icons.person, color: _twitterBlue),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: commentController, // Use the controller we created
                      style: TextStyle(color: _twitterTextColor),
                      decoration: InputDecoration(
                        hintText: 'Post your reply',
                        hintStyle: TextStyle(color: _twitterSecondaryTextColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: _twitterBlue),
                    onPressed: () {
                      // Use the same controller here
                      if (commentController.text.trim().isNotEmpty) {
                        Navigator.pop(context);
                        _addComment(post.id!, commentController.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}