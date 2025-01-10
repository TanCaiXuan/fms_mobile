import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/BottomNavBar.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  static String id = 'sign_in_screen';
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  // Creating firebase instance
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Function to implement Google SignIn
  Future<void> signup(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      // Getting user's credential
      UserCredential result = await auth.signInWithCredential(authCredential);
      User? user = result.user;

      if (user != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const BottomNavBar()));
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kGradientColorOne,
              kGradientColorTwo,
            ],
          ),
        ),
        child: Card(
          margin: const EdgeInsets.only(top: 200, bottom: 200, left: 30, right: 30),
          elevation: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Sign In",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: MaterialButton(
                  color: Colors.teal[100],
                  elevation: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 30.0,
                        width: 30.0,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('lib/images/google_icon.png'),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("Sign In with Google")
                    ],
                  ),
                  onPressed: () {
                    signup(context); // Corrected this line by adding braces for the function call
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
