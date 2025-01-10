import 'package:flood_management_system/screens/MyProfileScreen.dart';
import 'package:flood_management_system/screens/showIndivReport.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_management_system/screens/about_us.dart';
import 'constant.dart';

class PopUpMenuButton extends StatelessWidget {
  const PopUpMenuButton({
    super.key,
    required FirebaseAuth auth,
  }) : _auth = auth;

  final FirebaseAuth _auth;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.menu, color: kButtonTextColor),
      itemBuilder: (context) => [
        // Popup menu item 1
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.chrome_reader_mode,
                color: kButtonTextColor,
              ),
              SizedBox(width: 10),
              Text(
                "About Us",
                style: kTitleStyle2,
              ),
            ],
          ),
        ),

        // Popup menu item 2
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.book,
                color: kButtonTextColor,
              ),
              SizedBox(width: 10),
              Text(
                "Profile",
                style: kTitleStyle2,
              ),
            ],
          ),
        ),

        // Popup menu item 3
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.book,
                color: kButtonTextColor,
              ),
              SizedBox(width: 10),
              Text(
                "myIndiv",
                style: kTitleStyle2,
              ),
            ],
          ),
        ),
      ],
      offset: Offset(0, 56),
      color: kScaffoldColor,
      elevation: 2,
      onSelected: (int value) {
        if (value == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutUsScreen()),
          );
        } else if (value == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyProfileScreen()),
          );
        } else if (value == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShowIndivReport()),
          );
        }
      },
    );
  }
}
