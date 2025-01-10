import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flood_management_system/component/BottomNavBar.dart';

class MyProfileScreen extends StatefulWidget {
  static String id = 'my_profile_screen';
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign out method
  Future<void> _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const BottomNavBar()));
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: kScaffoldColor,

      ),
      backgroundColor: kScaffoldColor,
      body: user == null
          ? const Center(child: Text("No user is logged in."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center all children
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.photoURL ?? ""),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              color: kCardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                  children: [
                    // Name Row with Icon and Label
                    Row(
                      children: [
                        Icon(Icons.person, color: kButtonTextColor),
                        const SizedBox(width: 10),
                        Text(
                          "Name: ",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey, // Label text color
                          ),
                        ),
                      ],
                    ),
                    // Value below the label
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0), // Align value below label
                      child: Text(
                        "${user.displayName ?? "Not Available"}",
                        style: TextStyle(
                          fontSize: 18,
                          color: kButtonTextColor,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle long text
                        maxLines: 2, // Allow text to break into multiple lines if necessary
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email Row with Icon and Label
                    Row(
                      children: [
                        Icon(Icons.email, color: kButtonTextColor),
                        const SizedBox(width: 10),
                        Text(
                          "Email: ",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey, // Label text color
                          ),
                        ),
                      ],
                    ),
                    // Value below the label
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0), // Align value below label
                      child: Text(
                        "${user.email ?? "Not Available"}",
                        style: TextStyle(
                          fontSize: 18,
                          color: kButtonTextColor,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle long text
                        maxLines: 2, // Allow text to break into multiple lines if necessary
                      ),
                    ),
                    const SizedBox(height: 8),

                    // UID Row with Icon and Label
                    Row(
                      children: [
                        Icon(Icons.info, color: kButtonTextColor),
                        const SizedBox(width: 10),
                        Text(
                          "UID: ",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey, // Label text color
                          ),
                        ),
                      ],
                    ),
                    // Value below the label
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0), // Align value below label
                      child: Text(
                        "${user.uid}",
                        style: TextStyle(
                          fontSize: 18,
                          color: kButtonTextColor, // Value text color
                        ),
                        overflow: TextOverflow.ellipsis, // Handle long text
                        maxLines: 2, // Allow text to break into multiple lines if necessary
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
