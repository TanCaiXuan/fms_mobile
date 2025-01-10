import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_management_system/component/buildButtonCard.dart';
import 'package:flood_management_system/component/pop_up_menu_button.dart';
import 'package:flood_management_system/screens/ChecklistScreen.dart';
import 'package:flood_management_system/screens/qa_screen.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:flood_management_system/component/LogOut.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //ppt slide num
  final int _page = 0;
  final _auth = FirebaseAuth.instance;
  //log out
  final LogOut _logout = LogOut();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldLayoutBuilder(
        backgroundColorAppBar: const ColorBuilder(Colors.transparent, kAppBarColor),
        textColorAppBar: const ColorBuilder(kButtonTextColor),
        appBarBuilder: _appBar,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Image.asset(
                'lib/images/AppBarIMG.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.cover,
              ),
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.36,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  color: kScaffoldColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // First Button Card (Checklist)
                          Expanded(
                            flex: 1,
                            child: buildButtonCard(
                              label: 'Checklist',
                              icon: Icons.checklist,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChecklistScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 1),
                          // Second Button Card (Guide)
                          Expanded(
                            flex: 1,
                            child: buildButtonCard(
                              label: 'Guide',
                              icon: Icons.book_online,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QAScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: ImageSlideshow(
                          initialPage: 0,
                          indicatorColor: kAppBarColor,
                          indicatorBackgroundColor: kCardColor,
                          onPageChanged: (value) {
                            debugPrint('Page changed: $value');
                          },
                          autoPlayInterval: 3000,
                          isLoop: true,
                          children: [
                            Image.asset('lib/images/reminder_1.png', fit: BoxFit.fitWidth),
                            Image.asset('lib/images/reminder_2.png', fit: BoxFit.fitWidth),
                            Image.asset('lib/images/reminder_3.png', fit: BoxFit.fitWidth),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
    return AppBar(
      backgroundColor: colorAnimated.background,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "FMS",
        style: TextStyle(color: kButtonTextColor),
      ),

      leading: PopUpMenuButton(auth: _auth),

      actions: [
        IconButton(
          onPressed: () {
            _logout.signOut(context);
          },
          icon: const Icon(
            Icons.login_outlined,
            color: kButtonTextColor,
          ),
        ),
      ],
    );
  }
}
