import 'package:firebase_core/firebase_core.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flood_management_system/model/floodKnowledgeBase.dart';
import 'package:flood_management_system/model/frequentQA.dart';
import 'package:flood_management_system/screens/answerScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';


class QAScreen extends StatefulWidget {
  @override
  _QAScreenState createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _answer = '';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isUserQuestion = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    frequentQA.shuffle();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize Firebase: $e';
      });
    }
  }

  String? checkFrequentQA(String question) {
    for (var qa in frequentQA) {
      if (qa["question"]!.toLowerCase() == question.toLowerCase()) {
        return qa["answer"];
      }
    }
    return null;
  }

  Future<void> fetchAnswer(String question) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String? frequentAnswer = checkFrequentQA(question);

    if (frequentAnswer != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnswerScreen(
            question: question,
            answer: frequentAnswer,
          ),
        ),
      );
      setState(() {
        _isLoading = false;
        _isUserQuestion = false;
      });
      return;
    }

    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
      );

      String hint =
          "You are an advanced AI flood handling expert in Malaysia with extensive knowledge of service. Based on the user's question below, provide constructive answers in short. These recommendations should be realistic.";

      String knowledgeBaseContext = floodKnowledgeBase.join(" ");
      String prompt = "$hint $knowledgeBaseContext Question: $question";

      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _answer = response.text ?? 'No answer generated';
        _isLoading = false;
        _isUserQuestion = true;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnswerScreen(
            question: question,
            answer: _answer,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text("Q&A"),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: kScaffoldColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: <Widget>[
                  Text(
                    'Frequent Questions',
                    style: kTitleStyle3,
                  ),
                  SizedBox(height: 15),
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: frequentQA.length > 4 ? 4 : frequentQA.length,
                    itemBuilder: (context, index) {
                      final question = frequentQA[index]["question"];
                      final answer = frequentQA[index]["answer"];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnswerScreen(
                              question: question!,
                              answer: answer!,
                            ),
                          ),
                        ),
                        child: Card(
                          color: kGradientColorOne,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                question!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Ask more',
                    style: kTitleStyle3,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Enter your question here...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        String question = _questionController.text;
                        if (question.isNotEmpty) {
                          fetchAnswer(question);
                        } else {
                          setState(() {
                            _errorMessage = 'Please enter a question';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: kWeatherTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text(
                        'Ask',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(

                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kWeatherTextColor),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
