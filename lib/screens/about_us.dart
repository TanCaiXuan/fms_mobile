import 'package:flood_management_system/component/BottomNavBar.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';

import 'home_screen.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldColor,

      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "About Us",
          style:kTitleStyle2,
        ),

              //icon button
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined),
          tooltip: 'back',
          onPressed: () {
            setState(() {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNavBar()),
              );
            });
          },
        ),

      ),

      // Scrollable body content using SingleChildScrollView
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Program:',
                    style: kAboutUsStyle,
                  ),
                  Text(
                    'Bachelor of Software Engineering \n\n',
                    style: kFontFamily,
                  ),
                  Text(
                    'Subject Code:',
                    style: kAboutUsStyle,
                  ),
                  Text(
                    'BTIS 3204 \n\n',
                    style: kFontFamily,
                  ),
                  Text(
                    'Subject Name:',
                    style: kAboutUsStyle,
                  ),
                  Text(
                    'Final Year Project \n\n',
                    style: kFontFamily,
                  ),
                  Text(
                    'Lecturer Name:',
                    style: kAboutUsStyle,
                  ),
                  Text(
                    'Ms. Nur Shamilla Binti Selamat\n\n',
                    style: kFontFamily,
                  ),
                  Text(
                    'Academic Session:',
                    style: kAboutUsStyle,
                  ),
                  Text(
                    '2024B and 2024C \n\n',
                    style: kFontFamily,
                  ),
                  Text(
                    'Student:',
                    style: kAboutUsStyle,
                  ),
                  Text(
                    'B220038B TAN CAI XUAN \n\n',
                    style: kFontFamily,
                  ),
                  Text(
                    'Project Goal:',
                    style: kAboutUsStyle,
                  ),
                  Text(
                    'This project proposes an enhanced flood management system designed to integrate flood victims, improve reporting, and promote awareness.\n\n',
                    style: kFontFamily,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
