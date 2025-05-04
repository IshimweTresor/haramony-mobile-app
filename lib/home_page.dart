import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project/navigation_bar.dart';
import 'package:my_project/API/survey-tool.api.dart';
import 'package:my_project/models/survey_tool.model.dart';
import 'package:my_project/API/user.api.dart'; 
import 'package:my_project/models/user.model.dart';
import 'package:my_project/widgets/mypopup.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<SurveyTool> _surveys = [];
  String? _errorMessage;

  String _username = "User"; 
  bool _loadingUserInfo = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await UserApiService.getCurrentUser();
      
      if (user != null) {
        setState(() {
          _username = user.usernames; // Use the username from your User model
          _loadingUserInfo = false;
        });
      } else {
        setState(() {
          _loadingUserInfo = false;
        });
      }
    } catch (e) {
      print("Error loading user info: $e");
      setState(() {
        _loadingUserInfo = false;
      });
    }
  }

  // Add this method to the _HomePageState class

void _handleLogout(BuildContext context) async {
  // Show confirmation dialog
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Logout'),
        ),
      ],
    ),
  );
  
  // If user confirmed logout
  if (confirm == true) {
    // Call logout method
    await UserApiService.logout();
    
    // Navigate to login screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
  }
}

  // Load surveys from API
  Future<void> _loadSurveys() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final surveys = await SurveyApiService.getAllSurveys();
      
      setState(() {
        _surveys = surveys;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load surveys. Please try again.';
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 17, 39),
      
      body: 
        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, left: 20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello,",
                              style: GoogleFonts.poppins(
                                  fontSize: 18, color: Colors.white)),
                          // Replace TRESOR with dynamic username
                          _loadingUserInfo
                            ? SizedBox(
                                height: 22,
                                width: 120,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.white24,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                ),
                              )
                            : Text(_username,
                                style: GoogleFonts.poppins(
                                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("Households survey",
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
                        ],
                    ),
                  ),
                  Container(
  child: Column(
    children: [
      // Replace IconButton with MyPopupMenu
      MyPopupMenu(
        onSelected: (value) {
          // Handle menu selection
          switch (value) {
            case 'profile':
              Navigator.pushNamed(context, '/settings');
              break;
            case 'settings':
              Navigator.pushNamed(context, '/settings');
              break;
            case 'logout':
              _handleLogout(context);
              break;
            case 'Login':
              Navigator.pushNamed(context, '/');
              break;
          }
        },
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.search, color: Colors.white)
      )
    ],
  ),
)
                ],
              )
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)
                  ),
                  color: Color.fromARGB(255, 199, 205, 209),
                ),
                child: _isLoading 
                  ? _buildLoadingState()
                  : _errorMessage != null 
                    ? _buildErrorState()
                    : _buildSurveyList(),
              )
            )
          ],
        ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
  
  // Loading indicator
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading surveys...", 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
  
  // Error view
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(_errorMessage ?? "An error occurred", 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            )
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSurveys,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF002B49),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Try Again", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  // Survey list
  // Survey list
Widget _buildSurveyList() {
  if (_surveys.isEmpty) {
    return Center(
      child: Text(
        "No surveys available right now.",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  // Use Column with Expanded instead of Container
  return Column(
    children: [
      // Header text for surveys section
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Available Surveys",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF002B49)
              ),
            ),
            Text(
              "${_surveys.length} surveys",
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      
      // Expanded ensures ListView takes only the remaining space
      Expanded(
        child: RefreshIndicator(
          onRefresh: _loadSurveys,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              // Ensure proper scrolling behavior without overflow
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _surveys.length,
              itemBuilder: (context, index) {
                final survey = _surveys[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      leading: Icon(
                        survey.isValidToday
                          ? Icons.assignment
                          : Icons.assignment_late,
                        color: survey.isValidToday ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                      title: Text(
                        survey.title,
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        survey.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: survey.isValidToday
                        ? Icon(Icons.keyboard_arrow_right, color: Colors.black)
                        : null,
                      onTap: survey.isValidToday
                        ? () {
                            Navigator.pushNamed(
                              context,
                              '/survey',
                              arguments: survey.id
                            );
                          }
                        : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ],
  );
}
  }
