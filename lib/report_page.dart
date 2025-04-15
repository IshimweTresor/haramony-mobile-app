import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'navigation_bar.dart'; // Your custom nav bar

class IssueReportingPage extends StatefulWidget {
  @override
  _IssueReportingPageState createState() => _IssueReportingPageState();
}

class _IssueReportingPageState extends State<IssueReportingPage> {
  int _selectedIndex = 3;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String selectedCategory = 'Family';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _attachedFile;

  List<Map<String, dynamic>> submittedIssues = [];

  List<String> categories = ['Family', 'Security', 'Health', 'Education', 'Other'];

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
        Navigator.pushNamed(context, '/urubuga');
        break;
      case 3:
        Navigator.pushNamed(context, '/raporo');
        break;
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      setState(() {
        _attachedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitIssue() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        submittedIssues.add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'file': _attachedFile != null ? _attachedFile!.path.split('/').last : null,
          'category': selectedCategory,
          'date': selectedDate,
        });

        _titleController.clear();
        _descriptionController.clear();
        _attachedFile = null;
        selectedCategory = 'Family';
        selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Issue submitted successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text("Issue Reporting"),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDate(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(selectedDate, style: TextStyle(fontSize: 16))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Issue Title",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  SizedBox(height: 10),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Issue Description",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please describe the issue' : null,
                  ),
                  SizedBox(height: 10),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((String category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Upload Button
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickDocument,
                        icon: Icon(Icons.attach_file),
                        label: Text("Attach File"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      if (_attachedFile != null)
                        Expanded(
                          child: Text(
                            _attachedFile!.path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 12),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitIssue,
                      child: Text("Submit Issue"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // List of Submitted Issues
            Expanded(
              child: submittedIssues.isEmpty
                  ? Center(child: Text("No issues submitted yet."))
                  : ListView.builder(
                      itemCount: submittedIssues.length,
                      itemBuilder: (context, index) {
                        final issue = submittedIssues[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(Icons.warning, color: Colors.orange),
                            title: Text(issue['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Category: ${issue['category']}"),
                                Text("Date: ${issue['date']}"),
                                SizedBox(height: 4),
                                Text(issue['description']),
                                if (issue['file'] != null) Text("📎 ${issue['file']}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
