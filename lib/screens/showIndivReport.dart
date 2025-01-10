import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_management_system/model/individual.dart';
import 'package:flood_management_system/screens/ShowIndividualDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flood_management_system/screens/ShowMemberDetailScreen.dart';


class ShowIndivReport extends StatefulWidget {
  static String id = 'report_indiv_screen';

  const ShowIndivReport({super.key});

  @override
  State<ShowIndivReport> createState() => _ShowIndivReportState();
}

class _ShowIndivReportState extends State<ShowIndivReport> {
  late Future<List<Individual>> futureIndividuals;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    futureIndividuals = _fetchIndividuals();
  }

  Future<List<Individual>> _fetchIndividuals() async {
    List<Individual> individuals = [];
    try {
      print('Fetching individuals from Firestore...');
      final querySnapshot = await db.collection("individual_reports").get();
      print('Query snapshot: ${querySnapshot.docs.length} documents found');

      for (var docSnapshot in querySnapshot.docs) {
        print('${docSnapshot.id} => ${docSnapshot.data()}');
        individuals.add(
          Individual.fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id),
        );
      }
    } catch (e) {
      print('Error fetching individuals: $e');
    }
    return individuals;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Individual Report",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      body: Container(
        color: kScaffoldColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<Individual>>(
                  future: futureIndividuals,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No individual reports found"));
                    } else {
                      final individuals = snapshot.data!;
                      return ListView.builder(
                        itemCount: individuals.length,
                        itemBuilder: (context, index) {
                          final individual = individuals[index];
                          return Card(
                            color: kCardColor,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                individual.name,
                                style: kTitleStyle,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'IC Number: ${individual.ic_number}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Status: ',
                                      style: const TextStyle(color: Colors.grey), // Base style for "Status:"
                                      children: [
                                        TextSpan(
                                          text: individual.statusOfApproved == 'true' || individual.statusOfApproved.toLowerCase() == 'approved'
                                              ? 'Approved'
                                              : 'Pending',
                                          style: TextStyle(
                                            color: individual.statusOfApproved == 'true' || individual.statusOfApproved.toLowerCase() == 'approved'
                                                ? Colors.green
                                                : Colors.orange, // Color for "Approved" or "Pending"
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowIndividualDetailScreen(
                                      indivId: individual.indivId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
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
