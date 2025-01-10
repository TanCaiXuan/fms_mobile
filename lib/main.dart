import 'package:flood_management_system/screens/ngo_screen.dart';
import 'package:flood_management_system/screens/MyProfileScreen.dart';
import 'package:flood_management_system/screens/report_medical_history.dart';
import 'package:flood_management_system/screens/river_situation_screen.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_management_system/component/BottomNavBar.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flood_management_system/screens/SignInScreen.dart';
import 'package:flood_management_system/screens/information_screen.dart';
import 'package:flood_management_system/screens/home_screen.dart';
import 'package:flood_management_system/screens/report_indiv_manual_screen.dart';
import 'package:flood_management_system/screens/report_indiv_screen.dart';
import 'package:flood_management_system/screens/report_reason_screen.dart';
import 'package:flood_management_system/screens/report_road_screen.dart';
import 'package:flood_management_system/screens/report_flood_screen.dart';
import 'package:flood_management_system/screens/scan.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FMS());
}

class FMS extends StatelessWidget {
  const FMS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: const SplashScreen(),
      routes: <String, WidgetBuilder>{
        Scan.id: (context) => const Scan(),
        BottomNavBar.id: (context) => const BottomNavBar(),
        HomeScreen.id: (context) => const HomeScreen(),
        ReportRoadScreen.id: (context) => const ReportRoadScreen(),
        ReportReasonScreen.id: (context) => const ReportReasonScreen(),
        ReportFloodScreen.id: (context) => const ReportFloodScreen(),
        ReportIndividualScreen.id: (context) => const ReportIndividualScreen(),
        ReportIndividualManualScreen.id: (context) => const ReportIndividualManualScreen(),
        InformationScreen.id: (context) => const InformationScreen(),
        SignInScreen.id: (context) => const SignInScreen(),
        NgoScreen.id: (context) => NgoScreen(),
        RiverSituationScreen.id: (context) => RiverSituationScreen(),
        MyProfileScreen.id: (context) => MyProfileScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Function to check user authentication status
  Future<void> _checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Delay navigation to ensure the current frame is rendered first
    await Future.delayed(const Duration(seconds: 1)); // Optionally add a delay for smoother transitions

    // If the user is not signed in, navigate to SignInScreen
    if (user == null) {
      Navigator.pushReplacementNamed(context, SignInScreen.id);
    } else {
      Navigator.pushReplacementNamed(context, BottomNavBar.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kAppBarColor,
      body: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kButtonTextColor)
        ), // Show a loading indicator while checking
      ),
    );
  }
}
