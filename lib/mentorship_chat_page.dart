import 'package:flutter/material.dart';

class MentorshipChatPage extends StatefulWidget {
  final String mentorName;
  final String avatarUrl;

  MentorshipChatPage({required this.mentorName, required this.avatarUrl});

  @override
  _MentorshipChatPageState createState() => _MentorshipChatPageState();
}

class _MentorshipChatPageState extends State<MentorshipChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [
    {'text': 'Muraho neza, mbwira ikibazo ufite.', 'isMe': false},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({'text': _messageController.text.trim(), 'isMe': true});
      _messageController.clear();
    });
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Handle navigation based on the index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/settings');
        break;
      case 2:
        Navigator.pushNamed(context, '/forum');
        break;
      case 3:
        Navigator.pushNamed(context, '/report');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.avatarUrl)),
            SizedBox(width: 8),
            Text(widget.mentorName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['isMe'];

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(message['text']),
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
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: const Color.fromARGB(255, 179, 211, 228)),
                  onPressed: _sendMessage,
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
}
