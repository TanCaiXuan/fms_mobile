import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_management_system/component/pop_up_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:flood_management_system/screens/report_flood_screen.dart';
import 'package:flood_management_system/screens/report_road_screen.dart';
import 'package:flood_management_system/component/LogOut.dart';

class ReportReasonScreen extends StatefulWidget {
  static String id = 'report_reason_screen';

  const ReportReasonScreen({super.key});

  @override
  State<ReportReasonScreen> createState() => _ReportReasonScreenState();
}

class _ReportReasonScreenState extends State<ReportReasonScreen> {
  final _auth = FirebaseAuth.instance;
  final int _page = 1;
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
                                  MaterialPageRoute(builder: (context) => const ReportRoadScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0), // Padding around the content
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: const AssetImage('lib/images/road.png'),
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.withOpacity(0.5),
                                    BlendMode.modulate,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.0), // Adjusted top padding
                                  child: Text(
                                    "Road",
                                    style: kTitleStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0), // Space between cards
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
                                  MaterialPageRoute(builder: (context) => const ReportFloodScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0), // Padding around the content
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: const AssetImage('lib/images/flood.png'),
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.withOpacity(0.5),
                                    BlendMode.modulate,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.0), // Adjusted top padding
                                  child: Text(
                                    "Flood",
                                    style: kTitleStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50), // Space after the last card
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
        "Report",
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
