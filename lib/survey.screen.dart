import 'package:flutter/material.dart';
import 'API/survey-tool.api.dart';
import 'models/question.model.dart';
import 'models/survey_questions_response.model.dart';
import 'models/survey_answer.model.dart';
import 'models/location.model.dart';
import 'API/user.api.dart';

class SurveyQuestionsScreen extends StatefulWidget {
  @override
  _SurveyQuestionsScreenState createState() => _SurveyQuestionsScreenState();
}

class _SurveyQuestionsScreenState extends State<SurveyQuestionsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  SurveyQuestionsData? _surveyData;
  String? _surveyId;
  
  // Track the current question index
  int _currentQuestionIndex = 0;
  
  // Store the answers
  final Map<String, String> _answers = {};
  
  // Controllers for text fields
  final TextEditingController _textAnswerController = TextEditingController();
  
  // Location selection variables
  String _selectedProvince = "Eastern Province";
  String _selectedDistrict = "Nyagatare";
  String _selectedSector = "Karangazi";
  
  // Rwanda location data
  final List<String> _provinces = [
    "Eastern Province",
    "Kigali",
    "Northern Province",
    "Southern Province",
    "Western Province"
  ];
  
  final Map<String, List<String>> _districts = {
    "Eastern Province": ["Bugesera", "Gatsibo", "Kayonza", "Kirehe", "Ngoma", "Nyagatare", "Rwamagana"],
    "Kigali": ["Gasabo", "Kicukiro", "Nyarugenge"],
    "Northern Province": ["Burera", "Gakenke", "Gicumbi", "Musanze", "Rulindo"],
    "Southern Province": ["Gisagara", "Huye", "Kamonyi", "Muhanga", "Nyamagabe", "Nyanza", "Nyaruguru", "Ruhango"],
    "Western Province": ["Karongi", "Ngororero", "Nyabihu", "Nyamasheke", "Rubavu", "Rusizi", "Rutsiro"]
  };
  
  final Map<String, List<String>> _sectors = {
    "Nyagatare": ["Gatunda", "Karama", "Karangazi", "Katabagemu", "Kiyombe", "Matimba", "Mimuri", "Mukama", "Musheri", "Nyagatare", "Rukomo", "Rwemiyaga", "Rwempasha", "Tabagwe"],
    // Add more sectors as needed
  };

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the survey ID from route arguments
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String && args != _surveyId) {
      _surveyId = args;
      _loadSurveyQuestions(_surveyId!);
    }
  }
  
  @override
  void dispose() {
    _textAnswerController.dispose();
    super.dispose();
  }
  
  // Update districts when province changes
  void _updateDistricts(String province) {
    setState(() {
      _selectedProvince = province;
      if (_districts.containsKey(province) && _districts[province]!.isNotEmpty) {
        _selectedDistrict = _districts[province]![0];
        _updateSectors(_selectedDistrict);
      }
    });
  }
  
  // Update sectors when district changes
  void _updateSectors(String district) {
    setState(() {
      _selectedDistrict = district;
      if (_sectors.containsKey(district) && _sectors[district]!.isNotEmpty) {
        _selectedSector = _sectors[district]![0];
      } else {
        // Default sector if none are defined for this district
        _selectedSector = "Unknown";
      }
    });
  }
  
  // Get current location object
  Location _getCurrentLocation() {
    return Location(
      province: _selectedProvince,
      district: _selectedDistrict,
      sector: _selectedSector
    );
  }

  // Load survey questions
  Future<void> _loadSurveyQuestions(String surveyId) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final surveyData = await SurveyApiService.getSurveyQuestions(surveyId);
      
      if (surveyData != null) {
        setState(() {
          _surveyData = surveyData;
          _isLoading = false;
          _currentQuestionIndex = 0; // Reset to first question
          _answers.clear(); // Clear any previous answers
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load survey questions';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }
  
  // Submit all answers
  Future<void> _submitSurvey() async {
    if (_surveyData == null || _surveyId == null) return;
    
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Get current user
      final user = await UserApiService.getCurrentUser();
      if (user == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }
      
      // Get current location
      final location = _getCurrentLocation();
      
      // Create list of answers
      final List<SurveyAnswer> answersList = [];
       _surveyData!.questions.forEach((question) {
      if (_answers.containsKey(question.id)) {
        // Use the single response field for both open and closed questions
        answersList.add(SurveyAnswer(
          questionId: question.id,
          response: _answers[question.id],
          location: location, // Add location to each answer
        ));
      }
    });
      
      // Submit all answers
      final result = await SurveyApiService.submitSurveyResponses(_surveyId!, answersList);
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success']) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Survey submitted successfully!')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to submit survey';
        });
        
        // Show error message but don't pop
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error submitting survey: $e';
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 17, 39),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _surveyData?.toolTitle ?? 'Survey',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading 
        ? _buildLoadingState()
        : _errorMessage != null 
          ? _buildErrorState()
          : _buildSurveyContent(),
    );
  }
  
  // Loading indicator
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            "Loading survey...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
          Text(
            _errorMessage ?? "An error occurred",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_surveyId != null) {
                _loadSurveyQuestions(_surveyId!);
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Try Again", style: TextStyle(color: Color(0xFF002B49))),
          ),
        ],
      ),
    );
  }
  
  // Main survey content
  Widget _buildSurveyContent() {
    if (_surveyData == null || _surveyData!.questions.isEmpty) {
      return Center(
        child: Text(
          "No questions available for this survey.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }
    
    // Get current question
    final question = _surveyData!.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == _surveyData!.questions.length - 1;
    
    // Calculate progress
    final progress = (_currentQuestionIndex + 1) / _surveyData!.questions.length;
    
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 
                   AppBar().preferredSize.height - 
                   MediaQuery.of(context).padding.top,
      ),
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${_currentQuestionIndex + 1}/${_surveyData!.questions.length}",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
            
            // Location selection
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF002B49)),
                      SizedBox(width: 8),
                      Text(
                        "Fill Your Location below",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF002B49),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Province',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _selectedProvince,
                    items: _provinces.map((province) {
                      return DropdownMenuItem<String>(
                        value: province,
                        child: Text(province),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _updateDistricts(value);
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'District',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _selectedDistrict,
                          items: (_districts[_selectedProvince] ?? []).map((district) {
                            return DropdownMenuItem<String>(
                              value: district,
                              child: Text(district),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) _updateSectors(value);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Sector',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _selectedSector,
                          items: (_sectors[_selectedDistrict] ?? [_selectedSector]).map((sector) {
                            return DropdownMenuItem<String>(
                              value: sector,
                              child: Text(sector),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSector = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Question card
        // Question card
        Container(
        width: double.infinity,
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header (title, description, question text)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question title
                Text(
                  question.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B49),
                  ),
                ),
                SizedBox(height: 10),
                
                // Question description
                Text(
                  question.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 20),
                
                // Question text
                Text(
                  question.questionText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
            
            // Answer section - use Expanded here
            Expanded(
              child: question.isOpenEnded 
                ? _buildOpenQuestion(question)
                : _buildClosedQuestion(question),
            ),
          ],
        ),
          ),
            
            // Navigation buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden for first question)
                  _currentQuestionIndex > 0
                    ? TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        label: Text('Previous', style: TextStyle(color: Colors.white)),
                      )
                    : SizedBox(width: 100),  // Empty space for alignment
                  
                  // Next/Submit button
                  ElevatedButton(
                    onPressed: _canProceed(question) ? _saveAnswerAndContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isLastQuestion ? 'Submit' : 'Next',
                      style: TextStyle(
                        color: Color(0xFF002B49),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Save the current answer and move to next question
  void _saveAnswerAndContinue() {
    if (_surveyData == null) return;
    
    final currentQuestion = _surveyData!.questions[_currentQuestionIndex];
    
    // For open questions, save the text answer
    if (currentQuestion.isOpenEnded && _textAnswerController.text.isNotEmpty) {
      _answers[currentQuestion.id] = _textAnswerController.text;
      _textAnswerController.clear();
    }
    
    // Check if we've reached the end
    if (_currentQuestionIndex < _surveyData!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitSurvey();
    }
  }
  
  // Save the selected option for closed questions
  void _selectOption(String option) {
    if (_surveyData == null) return;
    
    final currentQuestion = _surveyData!.questions[_currentQuestionIndex];
    setState(() {
      _answers[currentQuestion.id] = option;
    });
  }
  
 // For open-ended questions (text input)
Widget _buildOpenQuestion(Question question) {
  // Set initial value if already answered
  if (_answers.containsKey(question.id) && _textAnswerController.text.isEmpty) {
    _textAnswerController.text = _answers[question.id]!;
  }
  
  return TextField(
    controller: _textAnswerController,
    maxLines: 5,
    minLines: 3, // Set minimum lines
    decoration: InputDecoration(
      hintText: 'Type your answer here...',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFF002B49), width: 2),
      ),
      contentPadding: EdgeInsets.all(15), // Add some padding
    ),
    onChanged: (value) {
      setState(() {
        if (value.isNotEmpty) {
          _answers[question.id] = value;
        } else {
          _answers.remove(question.id);
        }
      });
    },
  );
}
  
  // For closed-ended questions (multiple choice)
  // Update the closed question method to work better in scrolling layout

Widget _buildClosedQuestion(Question question) {
  return ListView.builder(
    shrinkWrap: true, // This is important for nested scrolling
    physics: NeverScrollableScrollPhysics(), // Disable scrolling for the inner ListView
    itemCount: question.options.length,
    itemBuilder: (context, index) {
      final option = question.options[index];
      final isSelected = _answers[question.id] == option;
      
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: ListTile(
          tileColor: isSelected ? Color(0xFFE0F7FA) : Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? Color(0xFF002B49) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          leading: isSelected
            ? Icon(Icons.check_circle, color: Color(0xFF002B49))
            : Icon(Icons.circle_outlined, color: Colors.grey),
          title: Text(
            option,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            _selectOption(option);
          },
        ),
      );
    },
  );
}
  
  // Check if user can proceed to the next question
  bool _canProceed(Question question) {
    if (question.isOpenEnded) {
      return _textAnswerController.text.isNotEmpty;
    } else {
      return _answers.containsKey(question.id);
    }
  }
}