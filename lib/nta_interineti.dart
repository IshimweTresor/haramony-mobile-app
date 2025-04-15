import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_project/navigation_bar.dart';

class NtaInterineti extends StatefulWidget {
  @override
  State<NtaInterineti> createState() => _NtaInterinetiState();
}

class _NtaInterinetiState extends State<NtaInterineti> {
  int _selectedIndex = 1;
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();

  List<Post> posts = [];

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _sendPost() {
    if (_textController.text.isEmpty && _image == null) return;

    setState(() {
      posts.insert(
        0,
        Post(
          text: _textController.text,
          image: _image,
          likes: 0,
          comments: [],
        ),
      );
      _textController.clear();
      _image = null;
    });
  }

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

  void _likePost(int index) {
    setState(() {
      posts[index].likes += 1;
    });
  }

  void _addComment(int index, String comment) {
    setState(() {
      posts[index].comments.add(comment);
    });
  }

  void _sharePost(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post shared!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 17, 39),
      appBar: AppBar(
        title: Text("Itumanaho", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 21, 17, 39),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _sendPost,
            icon: Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 199, 205, 209),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_image!, height: 150),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Andika igitekerezo...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: Icon(Icons.camera_alt),
                      label: Text("Fata Ifoto"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo),
                      label: Text("Hitamo Ifoto"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.text),
                          if (post.image != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(post.image!, height: 150),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.favorite, color: Colors.red),
                                onPressed: () => _likePost(index),
                              ),
                              Text('${post.likes} Likes'),
                              IconButton(
                                icon: Icon(Icons.comment),
                                onPressed: () {
                                  _showCommentDialog(index);
                                },
                              ),
                              Text('${post.comments.length} Comments'),
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () => _sharePost(post),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  void _showCommentDialog(int index) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tanga igitekerezo"),
        content: TextField(
          controller: commentController,
          decoration: InputDecoration(hintText: "Andika comment..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addComment(index, commentController.text);
            },
            child: Text("Ohereza"),
          ),
        ],
      ),
    );
  }
}

// Post model
class Post {
  final String text;
  final File? image;
  int likes;
  List<String> comments;

  Post({
    required this.text,
    this.image,
    this.likes = 0,
    this.comments = const [],
  });
}
