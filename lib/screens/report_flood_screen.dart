import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_management_system/component/pop_up_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:flood_management_system/screens/report_grp_screen.dart';
import 'package:flood_management_system/screens/report_indiv_screen.dart';
import 'package:flood_management_system/component/LogOut.dart';

class ReportFloodScreen extends StatefulWidget {
  static String id = 'report_flood_screen';

  const ReportFloodScreen({super.key});

  @override
  State<ReportFloodScreen> createState() => _ReportFloodScreenState();
}

class _ReportFloodScreenState extends State<ReportFloodScreen> {
  final _auth = FirebaseAuth.instance;
  final int _page = 1; // Ensure the correct initial page index
  final LogOut _logout = LogOut();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldLayoutBuilder(
        backgroundColorAppBar: const ColorBuilder(Colors.transparent, kAppBarColor),
        textColorAppBar: const ColorBuilder(kButtonTextColor),
        appBarBuilder: _appBar,
        child: Stack(
          children: [
            Image.asset(
              'lib/images/AppBarIMG.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.285,
              fit: BoxFit.cover,
            ),
            Container(

              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.25,
              ),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                color: kScaffoldColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView( // Added to make the content scrollable
                  child: Column(

                    children: [
                      const SizedBox(height: 45),
                      // Adjusted to have a fixed height and padding
                      AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Card(
                          color: kScaffoldColor,
                          elevation: 10,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color: kAppBarColor,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            splashColor: Colors.black,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => const ReportGroupScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0), // Padding around the content
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: const AssetImage('lib/images/group.png'),
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.withOpacity(0.95),
                                    BlendMode.modulate,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.0), // Adjusted top padding
                                  child: Text(
                                    "Group",
                                    style: kTitleStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Card(
                          color: kScaffoldColor,
                          elevation: 10,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color: kAppBarColor,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            splashColor: Colors.black,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => const ReportIndividualScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0), // Padding around the content
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: const AssetImage('lib/images/individual.png'),
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.withOpacity(0.95),
                                    BlendMode.modulate,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.0), // Adjusted top padding
                                  child: Text(
                                    "Individual",
                                    style: kTitleStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 45), // Space after the last card
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        "Flood",
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
