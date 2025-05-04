import 'package:flutter/material.dart';
import 'mentorship_chat_page.dart';

class MentorshipHomePage extends StatelessWidget {
  final List<Map<String, String>> mentors = [
    {
      'name': 'Umujyanama w’Imibanire',
      'topic': 'Ibibazo by’ingo',
      'avatar': 'https://i.pravatar.cc/150?img=10',
    },
    {
      'name': 'Umujyanama w’Imari',
      'topic': 'Ibibazo by’ubukungu',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Umujyanama w’Abana',
      'topic': 'Kurera no kwigisha abana',
      'avatar': 'https://i.pravatar.cc/150?img=14',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mentorship",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 17, 39),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: mentors.length,
        itemBuilder: (context, index) {
          final mentor = mentors[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(mentor['avatar']!),
            ),
            title: Text(mentor['name']!),
            subtitle: Text(mentor['topic']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MentorshipChatPage(
                    mentorName: mentor['name']!,
                    avatarUrl: mentor['avatar']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
