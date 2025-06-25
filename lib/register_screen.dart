import 'package:flutter/material.dart';
import 'API/user.api.dart';
import 'models/user.model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Location controllers
  final _sectorController = TextEditingController();
  final _cellController = TextEditingController();
  final _villageController = TextEditingController();
  final _isiboController = TextEditingController();

  // Error messages
  String? _nameError;
  String? _idNumberError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Toggle for location fields
  bool _showLocationFields = false;

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _sectorController.dispose();
    _cellController.dispose();
    _villageController.dispose();
    _isiboController.dispose();
    super.dispose();
  }

  // Validate name
  void _validateName(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _nameError = 'Enter your name';
      } else {
        _nameError = null;
      }
    });
  }

  // Validate ID number
  void _validateIdNumber(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _idNumberError = 'Enter your ID number';        
      } else if (value.length < 16) {
        _idNumberError = 'The national ID number must have at least 16 digits.';
      } else {
        _idNumberError = null;
      }
    });
  }

  // Validate phone
  void _validatePhone(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _phoneError = 'Enter your phone number.';
      } else if (!value.startsWith('+') && !RegExp(r'^07').hasMatch(value)) {
        _phoneError = 'Enter a complete phone number (e.g., 07... or +250...)';
      } else {
        _phoneError = null;
      }
    });
  }

  // Format phone number to match backend requirements
  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('+250')) {
      return phone;
    } else if (phone.startsWith('250')) {
      return '+$phone';
    } else if (phone.startsWith('0')) {
      return '+25$phone';
    } else {
      return '+250$phone';
    }
  }

  // Validate password
  void _validatePassword(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _passwordError = 'Enter your password';
      } else if (value.length < 8) {
        _passwordError = 'The password must be at least 8 characters long';
      } else {
        _passwordError = null;
      }
      
      // Also validate confirm password when password changes
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword(_confirmPasswordController.text);
      }
    });
  }

  // Validate confirm password
  void _validateConfirmPassword(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _confirmPasswordError = 'Confirm your password';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'The passwords do not match.';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  // Submit registration form
  void _submitForm() async {
    // Run all validations
    _validateName(_nameController.text);
    _validateIdNumber(_idNumberController.text);
    _validatePhone(_phoneController.text);
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    // Force UI update
    setState(() {});

    // Check if form is valid
    if (_nameError == null && 
        _idNumberError == null && 
        _phoneError == null &&
        _passwordError == null && 
        _confirmPasswordError == null) {
      
      setState(() {
        _isLoading = true;
      });

      try {
        // Format phone number
        String formattedPhone = _formatPhoneNumber(_phoneController.text);
        
        // Create location if any field is filled
        UserLocation? location;
        if (_showLocationFields && (_sectorController.text.isNotEmpty || 
                                   _cellController.text.isNotEmpty || 
                                   _villageController.text.isNotEmpty || 
                                   _isiboController.text.isNotEmpty)) {
          location = UserLocation(
            sector: _sectorController.text.isEmpty ? null : _sectorController.text,
            cell: _cellController.text.isEmpty ? null : _cellController.text,
            village: _villageController.text.isEmpty ? null : _villageController.text,
            isibo: _isiboController.text.isEmpty ? null : _isiboController.text,
          );
        }

        // Create user object
        final user = User(
          usernames: _nameController.text,
          idNumber: int.parse(_idNumberController.text),
          phoneNumber: formattedPhone,
          password: _passwordController.text,
          role: 'user',
          location: location,
        );

        // Call API
        final result = await UserApiService.register(user);

        // Handle result
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration was successful!')),
          );
          // Navigate to login
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding;
    final headerHeight = 140.0;
    final availableHeight = screenHeight - headerHeight - safeAreaPadding.top - safeAreaPadding.bottom;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 17, 39),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Harmony connect',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'living in peace in households',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: availableHeight,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 199, 205, 209),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002B49),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Name field with validation
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Your Name',
                      onChanged: _validateName,
                    ),
                    if (_nameError != null)
                      _buildErrorText(_nameError!),
                    const SizedBox(height: 15),
                    
                    // ID Number field with validation
                    _buildTextField(
                      controller: _idNumberController,
                      hintText: 'Id Number (16 digits)',
                      onChanged: _validateIdNumber,
                      keyboardType: TextInputType.number,
                    ),
                    if (_idNumberError != null)
                      _buildErrorText(_idNumberError!),
                    const SizedBox(height: 15),
                    
                    // Phone field with validation
                    _buildTextField(
                      controller: _phoneController,
                      hintText: 'Phone Number (format: 07... or +250...)',
                      onChanged: _validatePhone,
                      keyboardType: TextInputType.phone,
                    ),
                    if (_phoneError != null)
                      _buildErrorText(_phoneError!),
                    const SizedBox(height: 15),
                    
                    // Password field with validation
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password (at least 8 characters)',
                      isPassword: true,
                      onChanged: _validatePassword,
                    ),
                    if (_passwordError != null)
                      _buildErrorText(_passwordError!),
                    const SizedBox(height: 15),
                    
                    // Confirm Password field with validation
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      isPassword: true,
                      onChanged: _validateConfirmPassword,
                    ),
                    if (_confirmPasswordError != null)
                      _buildErrorText(_confirmPasswordError!),
                    const SizedBox(height: 15),
                    
                    // Location toggle
                    Row(
                      children: [
                        Text(
                          'Add location details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF002B49),
                          ),
                        ),
                        Spacer(),
                        Switch(
                          value: _showLocationFields,
                          onChanged: (value) {
                            setState(() {
                              _showLocationFields = value;
                            });
                          },
                          activeColor: Color(0xFF002B49),
                        ),
                      ],
                    ),
                    
                    // Location fields (only visible if toggled)
                    if (_showLocationFields) ...[
                      SizedBox(height: 15),
                      _buildTextField(
                        controller: _sectorController,
                        hintText: 'Sector',
                      ),
                      SizedBox(height: 15),
                      _buildTextField(
                        controller: _cellController,
                        hintText: 'Cell',
                      ),
                      SizedBox(height: 15),
                      _buildTextField(
                        controller: _villageController,
                        hintText: 'Village',
                      ),
                      SizedBox(height: 15),
                      _buildTextField(
                        controller: _isiboController,
                        hintText: 'Isibo',
                      ),
                    ],
                    
                    SizedBox(height: 30),
                    
                    // Register button
                    Center(
                      child: _isLoading
                        ? CircularProgressIndicator(
                            color: Color(0xFF002B49),
                          )
                        : ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF002B49),
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Color(0xFF002B49),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFF002B49),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 5),
      child: Text(
        text,
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}