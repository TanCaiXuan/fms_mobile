import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/model/ngo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NgoDetailsScreen extends StatelessWidget {
  final Ngo ngo;

  NgoDetailsScreen({required this.ngo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "NGO Details",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      backgroundColor: kScaffoldColor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView( // Enable scrolling
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ngo.ngoName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kButtonTextColor, // Text color
                ),
              ),
              SizedBox(height: 20),

              // Location Card
              Card(
                margin: EdgeInsets.only(bottom: 10),
                color: kScaffoldColor, // Set card color to kScaffoldColor
                child: ListTile(
                  leading: Icon(Icons.location_on, color: kButtonTextColor), // Location Icon
                  title: Text(
                    'Location: ${ngo.location}',
                    style: TextStyle(color: kButtonTextColor), // Set text color to kButtonTextColor
                  ),
                ),
              ),

              // Country Card
              Card(
                margin: EdgeInsets.only(bottom: 10),
                color: kScaffoldColor, // Set card color to kScaffoldColor
                child: ListTile(
                  leading: Icon(Icons.flag, color: kButtonTextColor), // Country Icon
                  title: Text(
                    'Country: ${ngo.country}',
                    style: TextStyle(color: kButtonTextColor), // Set text color to kButtonTextColor
                  ),
                ),
              ),

              // Work Areas Card
              Card(
                margin: EdgeInsets.only(bottom: 10),
                color: kScaffoldColor, // Set card color to kScaffoldColor
                child: ListTile(
                  leading: Icon(Icons.work, color: kButtonTextColor), // Work Areas Icon
                  title: Text(
                    'Work Areas: ${ngo.workAreas.join(', ')}',
                    style: TextStyle(color: kButtonTextColor), // Set text color to kButtonTextColor
                  ),
                ),
              ),

              // Sub Work Areas Card
              Card(
                margin: EdgeInsets.only(bottom: 10),
                color: kScaffoldColor, // Set card color to kScaffoldColor
                child: ListTile(
                  leading: Icon(Icons.subdirectory_arrow_right, color: kButtonTextColor), // Sub Work Areas Icon
                  title: Text(
                    'Sub Work Areas: ${ngo.subWorkAreas.join(', ')}',
                    style: TextStyle(color: kButtonTextColor), // Set text color to kButtonTextColor
                  ),
                ),
              ),

              // Website Card
              Card(
                margin: EdgeInsets.only(bottom: 10),
                color: kScaffoldColor, // Set card color to kScaffoldColor
                child: ListTile(
                  leading: Icon(Icons.web, color: kButtonTextColor), // Website Icon
                  title: Text(
                    'Website:\n${ngo.websiteUrl}',
                    style: TextStyle(color: kButtonTextColor), // Set text color to kButtonTextColor
                  ),
                ),
              ),

              // Facebook Card
              Card(
                margin: EdgeInsets.only(bottom: 10),
                color: kScaffoldColor, // Set card color to kScaffoldColor
                child: ListTile(
                  leading: FaIcon(FontAwesomeIcons.facebookF, color: kButtonTextColor), // Facebook Icon
                  title: Text(
                    'Facebook:\n${ngo.facebookUrl}',
                    style: TextStyle(color: kButtonTextColor), // Set text color to kButtonTextColor
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
