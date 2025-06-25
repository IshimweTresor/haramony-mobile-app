import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_project/API/user.api.dart';
import 'dart:io';

import 'package:my_project/models/issue.model.dart';
import 'package:my_project/models/category.model.dart';
import 'package:my_project/API/issues.api.dart';
import 'package:my_project/API/category.api.dart';
import 'navigation_bar.dart';

class IssueReportingPage extends StatefulWidget {
  @override
  _IssueReportingPageState createState() => _IssueReportingPageState();
}

class _IssueReportingPageState extends State<IssueReportingPage> {
  int _selectedIndex = 3;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String selectedCategory = 'Family';
  String? selectedCategoryId;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingCategories = false;
  String? _errorMessage;
  bool _isCustomCategory = false;
  bool _includeLocation = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  
  // Location controllers
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _cellController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _isiboController = TextEditingController();
  
  File? _attachedFile;

  List<Issue> issues = [];
  List<Category> _categories = [];
  
  // Map frontend categories to backend category IDs
  Map<String, String> categoryMap = {
    'Family': '642a69cfaff79334db16e4d8', // Default values if API fails
    'Security': '642a69cfaff79334db16e4d9',
    'Health': '642a69cfaff79334db16e4da',
    'Education': '642a69cfaff79334db16e4db',
    'Other': '642a69cfaff79334db16e4dc',
  };

  List<String> categories = ['Family', 'Security', 'Health', 'Education', 'Other'];

  @override
  void initState() {
    super.initState();
    selectedCategoryId = categoryMap[selectedCategory];
    _loadCategories();
    _loadIssues();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _sectorController.dispose();
    _cellController.dispose();
    _villageController.dispose();
    _isiboController.dispose();
    super.dispose();
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
        Navigator.pushNamed(context, '/urubuga');
        break;
      case 3:
        Navigator.pushNamed(context, '/raporo');
        break;
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final response = await CategoryApiService.getAllCategories();
      
      if (response['success']) {
        setState(() {
          _categories = response['categories'] as List<Category>;
          
          // Update category map with data from API
          if (_categories.isNotEmpty) {
            categoryMap.clear();
            categories.clear();
            
            for (var category in _categories) {
              if (category.id != null) {
                categoryMap[category.name] = category.id!;
                categories.add(category.name);
              }
            }
            
            // Set default selection if available
            if (categories.isNotEmpty) {
              selectedCategory = categories.first;
              selectedCategoryId = categoryMap[selectedCategory];
            }
          }
          
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _isLoadingCategories = false;
          // Keep using the default hardcoded categories
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadIssues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the current user first
      final user = await UserApiService.getCurrentUser();
      
      if (user == null || user.id == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User info not available. Please log in again.';
        });
        return;
      }
      
      // Now get issues created by this user
      final response = await IssueApiService.getIssuesByUserId(user.id!);
      
      if (response['success']) {
        setState(() {
          issues = response['issues'] as List<Issue>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load your issues';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        print('Error loading issues: $e');
        _isLoading = false;
      });
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

  Future<void> _submitIssue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        String? finalCategoryId;
        
        // Handle category selection or creation
        if (_isCustomCategory) {
          String newCategoryName = _customCategoryController.text.trim();
          
          // Check if this category already exists (case insensitive)
          bool categoryExists = false;
          for (String existingCategory in categories) {
            if (existingCategory.toLowerCase() == newCategoryName.toLowerCase()) {
              finalCategoryId = categoryMap[existingCategory];
              categoryExists = true;
              break;
            }
          }
          
          // If category doesn't exist, create it
          if (!categoryExists) {
            final createResponse = await CategoryApiService.createCategory(
              name: newCategoryName,
            );
            
            if (createResponse['success']) {
              final newCategory = createResponse['category'] as Category;
              finalCategoryId = newCategory.id;
              
              // Add to local lists for future use
              setState(() {
                categories.add(newCategory.name);
                categoryMap[newCategory.name] = newCategory.id!;
                _categories.add(newCategory);
              });
            } else {
              setState(() {
                _isSubmitting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(createResponse['message'] ?? "Failed to create category")),
              );
              return;
            }
          }
        } else {
          // Using an existing category
          finalCategoryId = categoryMap[selectedCategory];
        }

        // Create location if needed
        Location? location;
        if (_includeLocation && 
            (_sectorController.text.isNotEmpty || 
             _cellController.text.isNotEmpty || 
             _villageController.text.isNotEmpty || 
             _isiboController.text.isNotEmpty)) {
          
          location = Location(
            sector: _sectorController.text.isNotEmpty ? _sectorController.text : null,
            cell: _cellController.text.isNotEmpty ? _cellController.text : null,
            village: _villageController.text.isNotEmpty ? _villageController.text : null,
            isibo: _isiboController.text.isNotEmpty ? _isiboController.text : null,
          );
        }

        // Create the issue
        final response = await IssueApiService.createIssue(
          title: _titleController.text,
          description: _descriptionController.text,
          categoryId: finalCategoryId!,
          location: location,
        );

        setState(() {
          _isSubmitting = false;
        });

        if (response['success']) {
          // Clear form
          _titleController.clear();
          _descriptionController.clear();
          _customCategoryController.clear();
          _sectorController.clear();
          _cellController.clear();
          _villageController.clear();
          _isiboController.clear();
          _attachedFile = null;
          _isCustomCategory = false;
          _includeLocation = false;
          
          if (categories.isNotEmpty) {
            selectedCategory = categories.first;
            selectedCategoryId = categoryMap[selectedCategory];
          }
          
          selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Issue submitted successfully!")),
          );
          
          // Refresh issues list
          _loadIssues();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Failed to submit issue")),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return DateFormat('MMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 17, 39),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Issue Reporting", style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadIssues,
            tooltip: 'Refresh issues',
          ),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDate(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(selectedDate, 
              style: TextStyle(fontSize: 16, color: Colors.white),
            )),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadIssues,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
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

                      // Category section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Category', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isCustomCategory = !_isCustomCategory;
                                  });
                                },
                                icon: Icon(
                                  _isCustomCategory ? Icons.list_alt : Icons.add_circle_outline,
                                  size: 16,
                                  color: const Color.fromARGB(255, 21, 17, 39),
                                ),
                                label: Text(
                                  _isCustomCategory ? "Select existing" : "Create new",
                                  style: TextStyle(color: const Color.fromARGB(255, 21, 17, 39)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          _isLoadingCategories 
                            ? Center(child: CircularProgressIndicator(strokeWidth: 2))
                            : _isCustomCategory
                              ? TextFormField(
                                  controller: _customCategoryController,
                                  decoration: InputDecoration(
                                    labelText: "New Category Name",
                                    hintText: "Enter a new category",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) => value!.isEmpty ? 'Please enter a category name' : null,
                                )
                              : categories.isEmpty 
                                ? Center(child: Text("No categories available"))
                                : DropdownButtonFormField<String>(
                                    value: selectedCategory,
                                    items: categories.map((String category) {
                                      return DropdownMenuItem(value: category, child: Text(category));
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedCategory = newValue!;
                                        selectedCategoryId = categoryMap[newValue];
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Select Category',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) => value == null || value.isEmpty ? 'Please select a category' : null,
                                  ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Location toggle
                      Row(
                        children: [
                          Text('Include Location Details', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                          Spacer(),
                          Switch(
                            value: _includeLocation,
                            onChanged: (value) {
                              setState(() {
                                _includeLocation = value;
                              });
                            },
                            activeColor: const Color.fromARGB(255, 21, 17, 39),
                          ),
                        ],
                      ),
                      
                      // Location fields (only shown when toggle is on)
                      if (_includeLocation)
                        Column(
                          children: [
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _sectorController,
                              decoration: InputDecoration(
                                labelText: "Sector",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _cellController,
                              decoration: InputDecoration(
                                labelText: "Cell",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _villageController,
                              decoration: InputDecoration(
                                labelText: "Village",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _isiboController,
                              decoration: InputDecoration(
                                labelText: "Isibo",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),

                      // Upload Button
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickDocument,
                            icon: Icon(Icons.attach_file, color: Colors.white),
                            label: Text("Attach File"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 21, 17, 39),
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
                      SizedBox(height: 16),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitIssue,
                          child: _isSubmitting 
                            ? SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              )
                            : Text("Submit Issue"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 21, 17, 39),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Header for issues list
                Text(
                  "My Issues",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 21, 17, 39)
                  ),
                ),
                SizedBox(height: 8),
                
                // List of Issues
                _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _loadIssues,
                              child: Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 21, 17, 39),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : issues.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text("You haven't submitted any issues yet."),
                          )
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: issues.length,
                          itemBuilder: (context, index) {
                            final issue = issues[index];
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: EdgeInsets.symmetric(vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: _getStatusIcon(issue.status),
                                title: Text(issue.title, style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(issue.status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            issue.status,
                                            style: TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Category: ${issue.categoryInfo?.name ?? getCategoryName(issue.categoryId)}",
                                            style: TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "Submitted: ${_formatDate(issue.createdAt)}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        if (issue.location != null && issue.location!.sector != null)
                                          Expanded(
                                            child: Row(
                                              children: [
                                                SizedBox(width: 8),
                                                Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                                                SizedBox(width: 2),
                                                Expanded(
                                                  child: Text(
                                                    issue.location!.sector!,
                                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      issue.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () => _showIssueDetail(issue),
                              ),
                            );
                          },
                        ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
  
  // Helper methods for UI
  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'Under Review':
        return Icon(Icons.search, color: Colors.blue);
      case 'In Progress':
        return Icon(Icons.engineering, color: Colors.amber);
      case 'Resolved':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'Rejected':
        return Icon(Icons.cancel, color: Colors.red);
      default:
        return Icon(Icons.warning, color: Colors.orange);
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Under Review':
        return Colors.blue;
      case 'In Progress':
        return Colors.amber[700]!;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String getCategoryName(dynamic categoryId) {
    if (categoryId == null) return 'Unknown';
    
    // Case 1: categoryId is a String (just the ID)
    if (categoryId is String) {
      for (final entry in categoryMap.entries) {
        if (entry.value == categoryId) {
          return entry.key;
        }
      }
    }
    // Case 2: categoryId is a Map (full category object)
    else if (categoryId is Map) {
      // If it has a name property, use that directly
      if (categoryId['name'] != null) {
        return categoryId['name'].toString();
      }
      
      // Otherwise try to look up by ID if available
      if (categoryId['_id'] != null) {
        String id = categoryId['_id'].toString();
        for (final entry in categoryMap.entries) {
          if (entry.value == id) {
            return entry.key;
          }
        }
      }
    }
    
    return 'Unknown';
  }
  
  void _showIssueDetail(Issue issue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      issue.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Status chip
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(issue.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _getStatusIcon(issue.status),
                        SizedBox(width: 4),
                        Text(
                          issue.status,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Category and date
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Category: ${issue.categoryInfo?.name ?? getCategoryName(issue.categoryId)}",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    "Submitted: ${_formatDate(issue.createdAt)}",
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
              
              if (issue.updatedAt != null && issue.updatedAt != issue.createdAt)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.update, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          "Updated: ${_formatDate(issue.updatedAt)}",
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ],
                ),
                
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              
              // Description
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                issue.description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              // Location if available
              if (issue.location != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    SizedBox(height: 16),
                    Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (issue.location!.sector != null)
                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text("Sector"),
                        subtitle: Text(issue.location!.sector!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    if (issue.location!.cell != null)
                      ListTile(
                        leading: Icon(Icons.grid_3x3),
                        title: Text("Cell"),
                        subtitle: Text(issue.location!.cell!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    if (issue.location!.village != null)
                      ListTile(
                        leading: Icon(Icons.holiday_village),
                        title: Text("Village"),
                        subtitle: Text(issue.location!.village!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    if (issue.location!.isibo != null)
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text("Isibo"),
                        subtitle: Text(issue.location!.isibo!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              
              // Add action buttons for pending issues (like delete or edit)
              if (issue.status == 'Pending')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.delete),
                          label: Text('Delete Issue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Issue'),
                                content: Text('Are you sure you want to delete this issue?'),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () => Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: Text('Delete'),
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true && issue.id != null) {
                              try {
                                final response = await IssueApiService.deleteIssue(issue.id!);
                                
                                if (response['success']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Issue deleted successfully')),
                                  );
                                  _loadIssues();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response['message'] ?? 'Failed to delete issue')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}