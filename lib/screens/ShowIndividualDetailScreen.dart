import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/screens/EditIndivDetailsScreen.dart';
import 'package:flood_management_system/model/individual.dart';
import 'package:flood_management_system/component/constant.dart';

class ShowIndividualDetailScreen extends StatefulWidget {
  final String indivId;

  const ShowIndividualDetailScreen({super.key, required this.indivId});

  @override
  _ShowIndividualDetailScreenState createState() =>
      _ShowIndividualDetailScreenState();
}

class _ShowIndividualDetailScreenState
    extends State<ShowIndividualDetailScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late Future<Individual> individual;
  Individual? _individual;

  @override
  void initState() {
    super.initState();
    individual = _fetchIndividualDetails();
  }

  Future<Individual> _fetchIndividualDetails() async {
    try {
      final docSnapshot =
      await db.collection("individual_reports").doc(widget.indivId).get();
      if (docSnapshot.exists) {
        final individualData = Individual.fromMap(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
        setState(() {
          _individual = individualData; // Update the _individual variable
        });
        return individualData;
      } else {
        throw Exception("Individual not found");
      }
    } catch (e) {
      throw Exception("Error fetching individual: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Individual Details",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      body: Container(
        color: kScaffoldColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Individual>(
            future: individual,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return const Center(child: Text("No details found"));
              } else {
                final indiv = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIndividualCard(indiv),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // This function builds the individual card
  Widget _buildIndividualCard(Individual indiv) {
    return InkWell(
      onTap: () {
        if (_individual != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditIndivDetailsScreen(individual: _individual!),
            ),
          );
        }
      },
      child: Card(
        color: kCardColor,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildDetailsList(indiv),
        ),
      ),
    );
  }

  // This function builds the details list for the individual
  Widget _buildDetailsList(Individual indiv) {
    List<Map<String, String>> details = [
      {'Name': indiv.name},
      {'IC Number': indiv.ic_number},
      {'Phone Number': indiv.phone_number},
      {'Address': indiv.address},
      {'Gender': indiv.gender},
      {'Race': indiv.race ?? 'Not available'},
      {'Nationality': indiv.nationality},
      {'Birthday': indiv.birthday},
      {'Passport Number': indiv.passportNum ?? 'Not available'},
      {'Medical History': indiv.medical_history ?? 'Not available'},
      {'User ID': indiv.user_id},
      {'Status of Approval': indiv.statusOfApproved},
      {'Timestamp': indiv.timestamp.toDate().toString()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((detail) {
        final key = detail.keys.first;
        final value = detail[key]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 7, child: Text(value)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
