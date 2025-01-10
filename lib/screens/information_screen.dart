import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_management_system/component/pop_up_menu_button.dart';
import 'package:flood_management_system/screens/ngo_screen.dart';
import 'package:flood_management_system/screens/pps_screen.dart';
import 'package:flood_management_system/screens/river_situation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:flood_management_system/component/LogOut.dart';

class InformationScreen extends StatefulWidget {
  static String id = 'information_screen';

  const InformationScreen({Key? key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
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
              height: MediaQuery.of(context).size.height * 0.13,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.097),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  color: kScaffoldColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // First Card
                        _buildCard(
                          context,
                          '',
                          'lib/images/ngo.png',
                          NgoScreen(),
                        ),
                        const SizedBox(height: 10.0),
              
                        // Second Card
                        _buildCard(
                          context,
                          '',
                          'lib/images/river.jpg',
                          RiverSituationScreen(),
                        ),
                        const SizedBox(height: 10.0),
              
                        // Third Card (duplicate)
                        _buildCard(
                          context,
                          '',
                          'lib/images/pps.jpg',
                          PpsScreen(),
                        ),
                      ],
                    ),
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
        "Information",
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

  Widget _buildCard(BuildContext context, String title, String imagePath, Widget screen) {
    return AspectRatio(
      aspectRatio: 5 / 2.95,
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: AssetImage(imagePath),
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5),
                  BlendMode.modulate,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  title,
                  style: kTitleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
