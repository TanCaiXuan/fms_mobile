import 'package:flood_management_system/component/constant.dart';
import 'package:flood_management_system/screens/home_screen.dart';
import 'package:flood_management_system/screens/information_screen.dart';
import 'package:flood_management_system/screens/report_reason_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  static var id = 'btm_nav_screen';
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  List Screens = [
    const HomeScreen(),
    const ReportReasonScreen(),
    const InformationScreen(),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: kScaffoldColor,
      bottomNavigationBar: CurvedNavigationBar(
        color: kAppBarColor,
        buttonBackgroundColor: kScaffoldColor,
        backgroundColor: kScaffoldColor,
        index: _selectedIndex,
        items: [
          _buildNavItem(Icons.home, 'Home'),
          _buildNavItem(Icons.book, 'Report Issue'),
          _buildNavItem(Icons.info, 'Information'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: Screens[_selectedIndex],
    );
  }

  Widget _buildNavItem(IconData icon, String text) {
    return Tooltip(
      message: text,  // Tooltip message that will be displayed on long press
      padding: const EdgeInsets.all(8.0),
      verticalOffset: 20,  
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(color: Colors.white),
      child: Icon(
        icon,
        color: kButtonTextColor,
        size: 30,
      ),
    );
  }
}
