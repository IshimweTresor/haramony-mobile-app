import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  bool _isEditing = false;

  final TextEditingController _nameController =
      TextEditingController(text: 'Ishimwe Tresor');
  final TextEditingController _idController =
      TextEditingController(text: '1200080106436021');
  final TextEditingController _phoneController =
      TextEditingController(text: '250784107365');
  final TextEditingController _genderController =
      TextEditingController(text: 'Male');
  final TextEditingController _dobController =
      TextEditingController(text: '1998-01-01');

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void _editProfile() {
    setState(() {
      _isEditing = true;
    });
  }

  void _updateProfile() {
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Profile'),
        backgroundColor: const Color.fromARGB(255, 21, 17, 39),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildProfileSection(),
            if (_isEditing)
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 21, 17, 39),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 40,
            backgroundImage: _image != null
                ? FileImage(_image!)
                : const NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/3135/3135715.png')
                    as ImageProvider,
            child: const Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _nameController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 21, 17, 39),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'User ID: ${_idController.text}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        _isEditing
            ? _editableItem(Icons.person, 'Names', _nameController)
            : ProfileItem(
                icon: Icons.person,
                title: 'Names',
                value: _nameController.text),
        _isEditing
            ? _editableItem(Icons.badge, 'ID', _idController)
            : ProfileItem(
                icon: Icons.badge,
                title: 'ID',
                value: _idController.text),
        _isEditing
            ? _editableItem(Icons.phone, 'PhoneNumber', _phoneController)
            : ProfileItem(
                icon: Icons.phone,
                title: 'PhoneNumber',
                value: _phoneController.text),
        _isEditing
            ? _editableItem(Icons.person_outline, 'Gender', _genderController)
            : ProfileItem(
                icon: Icons.person_outline,
                title: 'Gender',
                value: _genderController.text),
        _isEditing
            ? _editableItem(Icons.calendar_today, 'Date of birth', _dobController)
            : ProfileItem(
                icon: Icons.calendar_today,
                title: 'Date of birth',
                value: _dobController.text),
      ],
    );
  }

  Widget _editableItem(
      IconData icon, String title, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 21, 17, 39).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color.fromARGB(255, 21, 17, 39)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 21, 17, 39).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 21, 17, 39),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 21, 17, 39),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
