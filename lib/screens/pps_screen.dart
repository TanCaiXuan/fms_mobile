import 'package:flood_management_system/component/constant.dart';
import 'package:flood_management_system/model/pps.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PpsScreen extends StatelessWidget {
  static String id = 'pps_screen';
  final CollectionReference ppsCollection = FirebaseFirestore.instance.collection('pps');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "PPS List",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      backgroundColor: kScaffoldColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: ppsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final ppsList = snapshot.data!.docs.map((doc) {
            final docData = doc.data() as Map<String, dynamic>;
            return Pps(
              baby_boys: docData['baby_boys'],
              baby_girls: docData['baby_girls'],
              boys: docData['boys'],
              capacity: docData['capacity'],
              district: docData['district'],
              families: docData['families'],
              girls: docData['girls'],
              men: docData['men'],
              name: docData['name'],
              open: docData['open'],
              subdistrict: docData['subdistrict'],
              victims: docData['victims'],
              women: docData['women'],
            );
          }).toList();

          return ListView.builder(
            itemCount: ppsList.length,
            itemBuilder: (context, index) {
              final pps = ppsList[index];
              return Card(
                color: kScaffoldColor, // Card background color set to kScaffoldColor
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                child: ListTile(
                  title: Text(
                    pps.name ?? 'No Name',
                    style: kTitleStyle6,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('District: ${pps.district ?? ''}',style: kTitleStyle4,),
                      Text('Capacity: ${pps.capacity ?? ''}', style: kTitleStyle4,),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PpsDetailScreen(pps: pps),
                      ),
                    );
                  },

                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PpsDetailScreen extends StatelessWidget {
  final Pps pps;

  const PpsDetailScreen({Key? key, required this.pps}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "PPS Details",
          style: kTitleStyle2
        ),
      ),
      backgroundColor: kScaffoldColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: kScaffoldColor,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pps.name ?? 'N/A'}',
                  style: kTitleStyle2,
                ),
                const Divider(),
                Text('District: ${pps.district ?? 'N/A'}' , style: kTitleStyle4,),
                Text('Capacity: ${pps.capacity ?? 'N/A'}' ,style: kTitleStyle4,),
                const SizedBox(height: 10),
                Text('Subdistrict: ${pps.subdistrict ?? 'N/A'}',style: kTitleStyle4),
                Text('Victims: ${pps.victims ?? 'N/A'}',style: kTitleStyle4),
                Text('Families: ${pps.families ?? 'N/A'}',style: kTitleStyle4),
                Text('Open: ${pps.open ?? 'N/A'}',style: kTitleStyle4),
                const SizedBox(height: 10),
                Text('Men: ${pps.men ?? 'N/A'}',style: kTitleStyle4),
                Text('Women: ${pps.women ?? 'N/A'}',style: kTitleStyle4),
                Text('Boys: ${pps.boys ?? 'N/A'}',style: kTitleStyle4),
                Text('Girls: ${pps.girls ?? 'N/A'}',style: kTitleStyle4),
                const SizedBox(height: 10),
                Text('Baby Boys: ${pps.baby_boys ?? 'N/A'}',style: kTitleStyle4),
                Text('Baby Girls: ${pps.baby_girls ?? 'N/A'}',style: kTitleStyle4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

