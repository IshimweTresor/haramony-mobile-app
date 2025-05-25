import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_project/API/mentor_chat.api.dart';
import 'package:my_project/API/user.api.dart';
import 'package:my_project/models/mentor_chat.model.dart';
import 'package:my_project/models/user.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mentorship_chat_page.dart';
import 'dart:math' as math;

class MentorshipHomePage extends StatefulWidget {
  @override
  _MentorshipHomePageState createState() => _MentorshipHomePageState();
}

class _MentorshipHomePageState extends State<MentorshipHomePage> with SingleTickerProviderStateMixin {
  List<User> mentors = [];
  List<Map<String, dynamic>> chats = [];
  Map<String, int> unreadCounts = {};
  bool isLoading = true;
  String? error;
  TabController? _tabController;
  bool isMentor = false;
  User? currentUser;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  
// FIX THE BROKEN LOGIC FLOW IN _loadData() method

Future<void> _loadData() async {
  setState(() {
    isLoading = true;
    error = null;
  });
  
  try {
    // First get current user to determine if they're a mentor
    debugPrint("Getting current user...");
    var currentUserData = await UserApiService.getCurrentUser();
    
    if (currentUserData == null) {
      setState(() {
        error = "Unable to retrieve user data";
        isLoading = false;
      });
      return;
    }

    // Debug the raw user data
    debugPrint('Current user data: ${currentUserData.toString()}');
    
    // Check if user is in the mentors list
    debugPrint("Loading available mentors list...");
    final availableMentors = await MentorChatApiService.getAvailableMentors();
    
    // More robust mentor detection
    bool userIsMentor = false;
      
    // Check primary condition - has mentorSpecialty
    if (currentUserData.mentorSpecialty != null && 
        currentUserData.mentorSpecialty!.isNotEmpty) {
      userIsMentor = true;
    } else {
      // Secondary check - is user in the mentors list?
      for (var mentor in availableMentors) {
        if (mentor.id == currentUserData.id) {
          userIsMentor = true;
          // Update current user with mentor data
          debugPrint('Found user in mentors list with specialty: ${mentor.mentorSpecialty}');
          break;
        }
      }
    }
      
    debugPrint('User is mentor: $userIsMentor (${currentUserData.usernames})');
      
    // Fix missing user ID and specialty by name matching
    if (currentUserData.id == null || currentUserData.id!.isEmpty) {
      debugPrint('Current user has null/empty ID, attempting to fix...');
      
      // Get available mentors
      final availableMentors = await MentorChatApiService.getAvailableMentors();
      
      // Try to match by name
      for (var mentor in availableMentors) {
        if (mentor.usernames == currentUserData?.usernames) {
          debugPrint('Found mentor match by name: ${mentor.id} with specialty ${mentor.mentorSpecialty}');
          
          // Create updated user with ID and specialty from mentors list
          currentUserData = User(
            id: mentor.id,
            usernames: currentUserData!.usernames,
            idNumber: currentUserData.idNumber,
            phoneNumber: currentUserData.phoneNumber,
            mentorSpecialty: mentor.mentorSpecialty,
            password: currentUserData.password,
          );
          
          // Store the fixed user data
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('user_data', jsonEncode({
            '_id': mentor.id,
            'usernames': currentUserData.usernames,
            'idNumber': currentUserData.idNumber, 
            'phoneNumber': currentUserData.phoneNumber,
            'mentorSpecialty': mentor.mentorSpecialty,
          }));
          
          userIsMentor = true;
          break;
        }
      }
    }
    
    // THIS IS THE CRITICAL FIX - Check mentor status before deciding which API to call
    if (userIsMentor) {
      // For mentors: Load their chats (to see users who messaged them)
      debugPrint("Loading mentor chats...");
      final mentorChats = await MentorChatApiService.getMentorChats();
      debugPrint("Loaded ${mentorChats.length} mentor chats");
      
      setState(() {
        chats = mentorChats;
        isMentor = true;
        currentUser = currentUserData;
        isLoading = false;
        
        // Extract unread counts for users
        Map<String, int> counts = {};
        for (var chatData in chats) {
          final chat = chatData['chat'] as MentorChat;
          final unreadCount = chatData['unreadCount'] as int;
          counts[chat.user] = (counts[chat.user] ?? 0) + unreadCount;
        }
        unreadCounts = counts;
      });
    } else {
      // For regular users: Load available mentors and their chats
      debugPrint("Loading available mentors and user chats...");
      final availableMentors = await MentorChatApiService.getAvailableMentors();
      final userChats = await MentorChatApiService.getUserChats();
      
      debugPrint("Loaded ${availableMentors.length} mentors and ${userChats.length} chats");
      
      setState(() {
        mentors = availableMentors;
        chats = userChats;
        isMentor = false;
        currentUser = currentUserData;
        isLoading = false;
        
        // Extract unread counts for mentors
        Map<String, int> counts = {};
        for (var chatData in chats) {
          final chat = chatData['chat'] as MentorChat;
          final unreadCount = chatData['unreadCount'] as int;
          counts[chat.mentor] = (counts[chat.mentor] ?? 0) + unreadCount;
        }
        unreadCounts = counts;
      });
    }
  } catch (e) {
    debugPrint('Error loading data: $e');
    setState(() {
      error = "Failed to load data: $e";
      isLoading = false;
    });
  }
}

  // Add this method to your MentorshipHomePageState class

Future<bool> _verifyUserIsMentor(User user) async {
  try {
    // First check the user object itself
    if (user.mentorSpecialty != null && user.mentorSpecialty!.isNotEmpty) {
      debugPrint('User has mentorSpecialty: ${user.mentorSpecialty}');
      return true;
    }
    
    // Then check the raw stored data
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final jsonData = jsonDecode(userData);
      if (jsonData.containsKey('mentorSpecialty') && 
          jsonData['mentorSpecialty'] != null && 
          jsonData['mentorSpecialty'].toString().isNotEmpty) {
        debugPrint('Found mentorSpecialty in stored data: ${jsonData['mentorSpecialty']}');
        return true;
      }
    }
    
    // Finally check available mentors list
    final mentorsList = await MentorChatApiService.getAvailableMentors();
    for (var mentor in mentorsList) {
      if (mentor.id == user.id) {
        debugPrint('User ID found in mentors list');
        return true;
      }
    }
    
    return false;
  } catch (e) {
    debugPrint('Error verifying mentor status: $e');
    return false;
  }
}


// Add this helper method
void _debugChats() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Debug Chat Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User is mentor: $isMentor'),
            Text('Current user ID: ${currentUser?.id ?? "null"}'),
            Text('Total chats: ${chats.length}'),
            Divider(),
            ...chats.map((chatData) {
              final chat = chatData['chat'] as MentorChat;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chat ID: ${chat.id}'),
                  Text('  Mentor: ${chat.mentor}'),
                  Text('  User: ${chat.user}'),
                  Text('  Is self chat: ${chat.mentor == chat.user}'),
                  Text('  Is current user mentor: ${chat.mentor == currentUser?.id}'),
                  Divider(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMentor ? "Mentor Dashboard" : "Mentorship",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 17, 39),
        iconTheme: IconThemeData(color: Colors.white),
// Add to your AppBar actions
actions: [
  IconButton(
    icon: Icon(Icons.refresh, color: Colors.white),
    onPressed: _loadData,
  ),
  // Debug button
  IconButton(
    icon: Icon(Icons.bug_report, color: Colors.white),
    onPressed: () {
      _debugChats();
    },
  ),
],

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: isMentor ? "My Students" : "Available Mentors"),
            Tab(text: "My Conversations"),
          ],
        ),
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : error != null
          ? _buildErrorView()
          : TabBarView(
              controller: _tabController,
              children: [
                // First tab - Shows either mentors or students depending on user role
                isMentor ? _buildStudentsView() : _buildMentorsView(),
                // Second tab - Conversations list for both roles
                _buildConversationsView(),
              ],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 21, 17, 39),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // View for mentors to see students who've messaged them
  Widget _buildStudentsView() {
    // Extract unique users from chats and exclude self-chats
    Map<String, StudentInfo> uniqueStudents = {};
    
    for (var chatData in chats) {
      final chat = chatData['chat'] as MentorChat;
      final userId = chat.user;
      final mentorId = chat.mentor;
      final unreadCount = chatData['unreadCount'] as int;
      
      // Skip self-chats (where mentor and user are the same)
  debugPrint('Processing chat: mentorId=$mentorId, userId=$userId, currentUserId=${currentUser?.id}');
  
  // Skip self-chats AND chats where current user isn't the mentor
  if (userId == mentorId || mentorId != currentUser?.id) {
    debugPrint('Skipping chat: user=$userId, mentor=$mentorId');
    continue;
  }
      
      // Get latest message info
      String latestMessage = "No messages";
      DateTime? latestMessageTime;
      
      String username = "User $userId";
    if (chat.messages.isNotEmpty) {
  // Use the last message in the list (most recent)
  latestMessage = chat.messages.last.content;
  latestMessageTime = chat.messages.last.createdAt;
  
  // Extract username from sender if available
  if (chat.messages.first.senderName != null && 
      chat.messages.first.senderName!.isNotEmpty) {
    username = chat.messages.first.senderName!; // Updates outer variable
  } else {
    // Try to find username from any message in the chat
    for (var msg in chat.messages) {
      if (msg.senderName != null && msg.senderName!.isNotEmpty) {
        username = msg.senderName!; // Updates outer variable
        break;
      }
    }
  }
  
  // Debug output to verify username extraction
  debugPrint('Extracted username for $userId: $username');
}
      
      // Update or create student info
      if (uniqueStudents.containsKey(userId)) {
        // Update if this chat has more recent messages
        if (latestMessageTime != null && 
            (uniqueStudents[userId]!.lastMessageTime == null || 
             latestMessageTime.isAfter(uniqueStudents[userId]!.lastMessageTime!))) {
          uniqueStudents[userId]!.lastMessage = latestMessage;
          uniqueStudents[userId]!.lastMessageTime = latestMessageTime;
          uniqueStudents[userId]!.chatId = chat.id!;
        }
        uniqueStudents[userId]!.unreadCount += unreadCount;
      } else {
        // Add new student
           uniqueStudents[userId] = StudentInfo(
      userId: userId,
      displayName: username,  // Use the extracted username instead of ID
      lastMessage: latestMessage,
      lastMessageTime: latestMessageTime,
      unreadCount: unreadCount,
      chatId: chat.id!,
    );
      }
    }
    
    // Convert to list and sort by most recent message
    final studentsList = uniqueStudents.values.toList();
    studentsList.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });
    
    // Empty state
    if (studentsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No one has contacted you yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'When users send you messages, they will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Show list of students
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: studentsList.length,
        itemBuilder: (context, index) {
          final student = studentsList[index];
          final avatarUrl = _getAvatarUrl(student.userId);
          
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openChatWithStudent(student),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        if (student.unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${student.unreadCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.displayName,
                            style: TextStyle(
                              fontWeight: student.unreadCount > 0 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            student.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: student.unreadCount > 0 
                                  ? Colors.black87 
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          if (student.lastMessageTime != null)
                            Text(
                              _formatTime(student.lastMessageTime!),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: const Color.fromARGB(255, 21, 17, 39),
                      ),
                      onPressed: () => _openChatWithStudent(student),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // View for regular users to see available mentors
  Widget _buildMentorsView() {
    if (mentors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No mentors available at the moment',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: mentors.length,
        itemBuilder: (context, index) {
          final mentor = mentors[index];
          final hasUnread = unreadCounts.containsKey(mentor.id) && unreadCounts[mentor.id]! > 0;
          final specialty = mentor.mentorSpecialty ?? "Umujyanama";
          final avatarUrl = _getAvatarUrl(mentor.usernames ?? "Unknown");
          
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openChatWithMentor(mentor),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        if (hasUnread)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${unreadCounts[mentor.id]}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentor.usernames,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            specialty,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: const Color.fromARGB(255, 21, 17, 39),
                      ),
                      onPressed: () => _openChatWithMentor(mentor),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // View to show ongoing conversations for both mentors and users
  Widget _buildConversationsView() {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Filter out self-chats where mentor and user are the same
    final filteredChats = chats.where((chatData) {
      final chat = chatData['chat'] as MentorChat;
      return chat.mentor != chat.user;
    }).toList();

    if (filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: filteredChats.length,
        itemBuilder: (context, index) {
          final chatData = filteredChats[index];
          final chat = chatData['chat'] as MentorChat;
          final unreadCount = chatData['unreadCount'] as int;
          
          // Determine whose profile to show based on user role
          String personId;
          String personName;
          String personAvatar;
          
          if (isMentor) {
            // Mentors see the user who messaged them
            personId = chat.user;
            personName = _getUserDisplayName(personId);
            personAvatar = _getAvatarUrl(personId);
          } else {
            // Users see the mentor they're chatting with
            personId = chat.mentor;
            
            // Try to find mentor in the mentors list
            final mentorData = mentors.firstWhere(
              (m) => m.id == personId,
              orElse: () => User(
                id: personId,
                usernames: "Unknown Mentor",
                idNumber: 0,
                phoneNumber: "",
              ),
            );
            
            personName = mentorData.usernames;
            personAvatar = _getAvatarUrl(personName);
          }
          
          // Get last message and time
          final lastMessage = chat.messages.isNotEmpty 
              ? chat.messages.last.content
              : "No messages yet";
          
          final lastMessageTime = chat.messages.isNotEmpty && chat.messages.last.createdAt != null
              ? _formatTime(chat.messages.last.createdAt!)
              : "";
          
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openExistingChat(personName, personAvatar, personId, chat.id ?? ""),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(personAvatar),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                personName,
                                style: TextStyle(
                                  fontWeight: unreadCount > 0 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                lastMessageTime,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unreadCount > 0 
                                  ? Colors.black87 
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Helper function to generate a display name for a user ID
  String _getUserDisplayName(String userId) {
    return "User " + userId.substring(0, math.min(8, userId.length));
  }
  
  // Helper function to generate an avatar URL
  String _getAvatarUrl(String input) {
    final hash = input.hashCode.abs() % 99;
    return 'https://i.pravatar.cc/150?img=$hash';
  }
  
  // Format timestamp for display
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else if (messageDate == yesterday) {
      return "Yesterday";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }

  // Open a chat with a mentor (for regular users)
  void _openChatWithMentor(User mentor) async {
    if (mentor.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Mentor has no ID')),
      );
      return;
    }
    
    try {
      String? existingChatId;
      
      // Check if a chat already exists with this mentor
      for (var chatData in chats) {
        final chat = chatData['chat'] as MentorChat;
        if (chat.mentor == mentor.id) {
          existingChatId = chat.id;
          break;
        }
      }
      
      // Navigate to chat page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentorshipChatPage(
            mentorName: mentor.usernames,
            avatarUrl: _getAvatarUrl(mentor.usernames),
            mentorId: mentor.id,
            chatId: existingChatId,
          ),
        ),
      );
      
      // Reload data when returning
      _loadData();
    } catch (e) {
      debugPrint('Error opening chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: $e')),
      );
    }
  }

  // Open a chat with a student (for mentors)
  void _openChatWithStudent(StudentInfo student) async {
    try {
      // Navigate to chat page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentorshipChatPage(
            mentorName: student.displayName,
            avatarUrl: _getAvatarUrl(student.userId),
            mentorId: currentUser?.id,
            chatId: student.chatId,
          ),
        ),
      );
      
      // Reload data when returning
      _loadData();
    } catch (e) {
      debugPrint('Error opening chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: $e')),
      );
    }
  }

  // Open an existing chat
  void _openExistingChat(String personName, String avatarUrl, String personId, String chatId) async {
    if (chatId.isEmpty) {
      debugPrint('Error: Empty chat ID');
      return;
    }
    
    try {
      // Find the correct mentor ID from the chat
      String? mentorId;
      
      for (var chatData in chats) {
        final chat = chatData['chat'] as MentorChat;
        if (chat.id == chatId) {
          mentorId = chat.mentor;
          break;
        }
      }
      
      if (mentorId == null) {
        mentorId = isMentor ? currentUser?.id : personId;
      }
      
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentorshipChatPage(
            mentorName: personName,
            avatarUrl: avatarUrl,
            mentorId: mentorId,
            chatId: chatId,
          ),
        ),
      );
      
      // Reload data when returning
      _loadData();
    } catch (e) {
      debugPrint('Error opening chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: $e')),
      );
    }
  }
}

// Helper class to store student information for mentors
class StudentInfo {
  final String userId;
  final String displayName;
  String lastMessage;
  DateTime? lastMessageTime;
  int unreadCount;
  String chatId;
  
  StudentInfo({
    required this.userId,
    required this.displayName,
    required this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.chatId,
  });
}