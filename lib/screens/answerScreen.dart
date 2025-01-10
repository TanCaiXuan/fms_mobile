import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/material.dart';

class AnswerScreen extends StatelessWidget {
  final String question;
  final String answer;

  const AnswerScreen({required this.question, required this.answer});

  String cleanAnswer(String rawAnswer) {

    String cleanedAnswer = rawAnswer.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
          (match) => '${match.group(1)}\n', // Remove any colons and just add the title followed by a newline
    );

    List<String> sentences = cleanedAnswer.split('.').map((sentence) {
      return sentence.trim(); // Trim leading/trailing space
    }).toList();

    sentences = sentences.where((sentence) => sentence.isNotEmpty).toList();

    // Join sentences back together with line breaks for better readability
    return sentences.join('.\n');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text("Answer"),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: kScaffoldColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Card for the Question
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: Icon(Icons.help_outline, color: kButtonTextColor),
                  title: Text(
                    'Question:',
                    style: kTitleStyle2,
                  ),
                  subtitle: Text(
                    question,
                    style: kTitleStyle3,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Card for the Answer
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: Icon(Icons.comment, color: Colors.green),
                  title: Text(
                    'Answer:',
                    style: kTitleStyle2,
                  ),
                  subtitle: Text(
                    cleanAnswer(answer),
                    style: kTitleStyle4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
