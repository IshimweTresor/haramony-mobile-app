import 'package:flutter/material.dart';
import 'package:my_project/API/mentor_chat.api.dart';
import 'package:my_project/API/user.api.dart';
import 'package:my_project/models/mentor_chat.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MentorshipChatPage extends StatefulWidget {
  final String mentorName;
  final String avatarUrl;
  final String? mentorId;
  final String? chatId;

  MentorshipChatPage({
    required this.mentorName, 
    required this.avatarUrl,
    this.mentorId,
    this.chatId,
  });

  @override
  _MentorshipChatPageState createState() => _MentorshipChatPageState();
}

class _MentorshipChatPageState extends State<MentorshipChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> messages = [];
  bool isLoading = true;
  String? error;
  String? chatId;
  String? currentUserId;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Helper to extract sender ID from different formats

String _extractSenderId(dynamic sender) {
  if (sender is String) {
    return sender;
  } else if (sender is Map) {
    return sender['_id']?.toString() ?? '';
  }
  return '';
}

// Update the _initialize method to ensure the currentUserId is set

Future<void> _initialize() async {
  try {
    setState(() {
      isLoading = true;
      error = null;
    });

    // Get current user and ensure we have their ID before continuing
    debugPrint('Fetching current user...');
    final user = await UserApiService.getCurrentUser();
    
    if (user == null || user.id == null) {
      // If getCurrentUser fails, try a fallback approach
      final storedUserId = await _getStoredUserId();
      
      if (storedUserId != null) {
        debugPrint('Using stored user ID: $storedUserId');
        setState(() {
          currentUserId = storedUserId;
        });
      } else {
        setState(() {
          error = "Unable to identify current user";
          isLoading = false;
        });
        return;
      }
    } else {
      debugPrint('Current user ID from API: ${user.id}');
      setState(() {
        currentUserId = user.id;
      });
      // Store for future use
      _storeUserId(user.id!);
    }
    
    // Now load the chat history after we have confirmed the current user ID
    await _loadChatHistory();
    
  } catch (e) {
    debugPrint('Error in initialization: $e');
    setState(() {
      error = "Error initializing chat: $e";
      isLoading = false;
    });
  }
}

// Add these helper methods for user ID storage
Future<void> _storeUserId(String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', userId);
  } catch (e) {
    debugPrint('Error storing user ID: $e');
  }
}

Future<String?> _getStoredUserId() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentUserId');
  } catch (e) {
    debugPrint('Error retrieving stored user ID: $e');
    return null;
  }
}
  Future<void> _loadChatHistory() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (widget.chatId != null && widget.chatId!.isNotEmpty) {
        // Load existing chat
        final chat = await MentorChatApiService.getChatHistory(widget.chatId!);
        
        // Mark messages as read
        await MentorChatApiService.markMessagesAsRead(widget.chatId!);
        
        setState(() {
          messages = chat.messages;
          chatId = chat.id;
          isLoading = false;
        });
        
        debugPrint('Loaded ${messages.length} messages for chat ${widget.chatId}');
      } else {
        // No existing chat, start with empty messages
        setState(() {
          messages = [];
          isLoading = false;
        });
        debugPrint('No existing chat ID provided');
      }
    } catch (e) {
      setState(() {
        error = "Failed to load chat history: $e";
        isLoading = false;
      });
      debugPrint('Error loading chat history: $e');
    }
  }

void _sendMessage() async {
  if (_messageController.text.trim().isEmpty) return;

    if (currentUserId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to identify current user')),
    );
    // Try to re-initialize
    _initialize();
    return;
  }
  
  final messageText = _messageController.text.trim();
  _messageController.clear();
  
  // Show optimistic UI update
  setState(() {
    messages.add(ChatMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',  // Generate a temporary ID
      sender: currentUserId ?? '',
      content: messageText,
      isRead: false,
      createdAt: DateTime.now(),
    ));
  });
  
  try {
    if (chatId == null && widget.mentorId != null) {
      debugPrint('Starting new chat with mentor ID: ${widget.mentorId}');
      // Start a new chat
      final newChat = await MentorChatApiService.startChat(
        widget.mentorId!,
        messageText,
      );
      
      setState(() {
        chatId = newChat.id;
        messages = newChat.messages;
      });
      
      debugPrint('New chat created with ID: ${newChat.id}');
    } else if (chatId != null) {
      debugPrint('Sending message to existing chat: $chatId');
      // Send message to existing chat
      final result = await MentorChatApiService.sendMessage(
        chatId!,
        messageText,
      );
      
      // Reload to get server-synced messages
      await _loadChatHistory();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send message: $e')),
    );
    debugPrint('Error sending message: $e');
    
    // Reload the chat to restore correct state
    await _loadChatHistory();
  }
}

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Special case for forum tab - pop back to forum
    if (index == 2) {
      Navigator.pop(context);
      return;
    }
    
    // Handle navigation based on the index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/report');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 17, 39),
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.avatarUrl)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.mentorName,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Update the AppBar actions

actions: [
  IconButton(
    icon: Icon(Icons.refresh, color: Colors.white),
    onPressed: _loadChatHistory,
  ),
  // Add debug button
  IconButton(
    icon: Icon(Icons.bug_report, color: Colors.white),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Debug Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current user ID: ${currentUserId ?? "NULL"}'),
              Text('Mentor ID: ${widget.mentorId ?? "NULL"}'),
              Text('Chat ID: ${chatId ?? "NULL"}'),
              Text('Message count: ${messages.length}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Reinitialize'),
              onPressed: () {
                Navigator.pop(context);
                _initialize();
              },
            ),
          ],
        ),
      );
    },
  ),
],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
              ? Center(child: CircularProgressIndicator())
              : error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadChatHistory,
                            child: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 21, 17, 39),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, 
                               size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : // Replace just the ListView.builder part with this implementation:

ListView.builder(
  padding: EdgeInsets.all(16),
  reverse: false,
  itemCount: messages.length,
  itemBuilder: (context, index) {
    final message = messages[index];
    
    final senderIdFromMessage = _extractSenderId(message.sender);
    
    // Try multiple approaches to determine if this is the current user's message
    bool isMe = false;
    
    // First check: Using current user ID if available
    if (currentUserId != null) {
      isMe = senderIdFromMessage == currentUserId;
    } else {
      // Fallback check: If we can't identify the current user, use the widget.mentorId
      // Messages NOT from the mentor are assumed to be from the user
      isMe = widget.mentorId != null && senderIdFromMessage != widget.mentorId;
    }
    
    // Print debug info to help diagnose
    debugPrint('Message $index - sender: ${message.sender}, currentUserId: $currentUserId, isMe: $isMe');
    
    // Determine if the message is from a mentor
    final isMentor = !isMe && widget.mentorId == message.sender;
    
    // Choose appropriate colors based on sender
    final bubbleColor = isMe 
        ? Colors.blue[100] 
        : (isMentor ? Color.fromARGB(255, 230, 225, 255) : Colors.grey[200]);
    
    // Choose text color
    final textColor = isMe 
        ? Colors.black87 
        : (isMentor ? Colors.deepPurple[900] : Colors.black87);
    
    // Determine sender name to display
    final senderName = isMe 
        ? 'You' 
        : (isMentor ? widget.mentorName : 'User');
    
    // Only show sender name if it's a new sender or first message
    final showSenderName = index == 0 || 
        (index > 0 && messages[index-1].sender != message.sender);

    return Align(
      // This is the key: align the whole message bubble to left or right
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        // This keeps text alignment within the bubble
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Make column tight to content
        children: [
          // Show sender name when needed
          if (showSenderName)
            Padding(
              padding: EdgeInsets.only(
                top: index > 0 ? 16 : 0,
                bottom: 4,
              ),
              child: Text(
                senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isMe 
                      ? Colors.blue[800] 
                      : (isMentor ? Colors.deepPurple[700] : Colors.grey[700]),
                ),
              ),
            ),
          
          // Message bubble
          Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            constraints: BoxConstraints(
              // This constrains the bubble to a maximum width
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              // Different border radius for each side depending on sender
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 16 : 0),
                topRight: Radius.circular(isMe ? 0 : 16),
                bottomLeft: Radius.circular(16), 
                bottomRight: Radius.circular(16),
              ),
              // Add different border styles for mentor messages
              border: isMentor ? Border.all(
                color: Colors.deepPurple.withOpacity(0.3),
                width: 1,
              ) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message content
                Text(
                  message.content,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                
                // Message timestamp and read status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.createdAt != null ? _formatTime(message.createdAt!) : '',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 4),
                    
                    // Show read status for user's messages
                    if (isMe)
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 12,
                        color: message.isRead ? Colors.blue : Colors.grey[400],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Andika ubutumwa...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 21, 17, 39),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else if (messageDate == yesterday) {
      return "Yesterday ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    }
  }
}