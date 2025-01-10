import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flood_management_system/screens/SignInScreen.dart';

class LogOut {
  Future<void> signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Sign out from Google Sign-In
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Navigate back to the login screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const SignInScreen()));
    } catch (error) {
      print("Error signing out: $error");
    }
  }
}
