import 'package:flutter/material.dart';
import 'API/user.api.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers to get input values
  final TextEditingController _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Error messages
  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate username
  void _validateUsername(String? value) {
  setState(() {
    if (value == null || value.isEmpty) {
      _usernameError = 'Andika amazina yawe';
    } else {
      _usernameError = null;
    }
  });
}

  // Validate password
  void _validatePassword(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _passwordError = 'Andika ijambo banga';
      } else if (value.length < 6) {
        _passwordError = 'Ijambo banga rigomba kuba nibura inyuguti 6';
      } else {
        _passwordError = null;
      }
    });
  }

  // Submit form
  void _submitForm() async {
  _validateUsername(_usernameController.text);
  _validatePassword(_passwordController.text);

  setState(() {});

  if (_usernameError == null && _passwordError == null) {
    setState(() {
      _isLoading = true;
    });

    final result = await UserApiService.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding;
    final headerHeight = 140.0; // Approximate height of your top section
    final availableHeight =
        screenHeight - headerHeight - safeAreaPadding.top - safeAreaPadding.bottom;

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
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kwinjira',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002B49),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Username field with validation
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Amazina yawe',
                        onChanged: _validateUsername,
                      ),
                      if (_usernameError != null)
                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 5),
                          child: Text(
                            _usernameError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 15),
                      
                      // Password field with validation
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Ijambo banga',
                        isPassword: true,
                        onChanged: _validatePassword,
                      ),
                      if (_passwordError != null)
                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 5),
                          child: Text(
                            _passwordError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 40),
                      
                      // Login button
                      Center(
                        child: _isLoading
                            ? CircularProgressIndicator(
                                color: Color(0xFF002B49),
                              )
                            : ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF002B49),
                                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.login,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Nta konti ufite?',
                              style: TextStyle(
                                color: Color(0xFF002B49),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                'Kwiyandikisha',
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
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text(
                            'Wibagiwe ijambo banga?',
                            style: TextStyle(
                              color: Color(0xFF002B49),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    void Function(String?)? onChanged,
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