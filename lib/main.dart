import 'package:flutter/material.dart';
import 'package:my_project/forum_page.dart';
import 'package:my_project/mentorship_chat_page.dart';
import 'login_screen.dart';
import 'home_page.dart';
import 'profile_screen.dart';
import 'nta_interineti.dart';
import 'report_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(bodyMedium: TextStyle(fontFamily: 'Poppins')),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/settings': (context) => ProfileScreen(),
        '/nta_interineti': (context) => NtaInterineti(),
        '/forum': (context) => MentorshipHomePage(),
        '/report': (context) => IssueReportingPage(),
        'mentorship_chat':
            (context) => MentorshipChatPage(
              mentorName: ModalRoute.of(context)!.settings.arguments as String,
              avatarUrl: 'https://i.pravatar.cc/150?img=10',
            ),
      },
    );
  }
}
