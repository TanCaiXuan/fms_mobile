import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_management_system/component/BottomNavBar.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/material.dart';

class ReportMedicalHistoryScreen extends StatefulWidget {
  const ReportMedicalHistoryScreen({
    super.key,
    required this.name,
    required this.birthday,
    this.gender,
    this.race,
    required this.ic_number,
    required this.phone_number,
    required this.address,
    required this.location,
    required this.passportNum,
    required this.nationality,
  });

  final String name;
  final String birthday;
  final String? gender;
  final String? race;
  final String ic_number;
  final String phone_number;
  final String address;
  final String location;
  final String passportNum;
  final String nationality;

  @override
  State<ReportMedicalHistoryScreen> createState() =>
      _ReportMedicalHistoryScreenState();
}


class _ReportMedicalHistoryScreenState extends State<ReportMedicalHistoryScreen> {
  // List of medical conditions
  List<String> medicalConditions = [
    "Allergy History",
    "Arthritis",
    "Asthma/COPD",
    "Autoimmune Disease",
    "Brain Infection",
    "Cancer",
    "Chronic Kidney Disease - Requires dialysis",
    "Chronic Kidney Disease - No dialysis required",
    "Chronic Lung Disease",
    "Chronic Skin Illness",
    "Congenital Gastrointestinal Disease",
    "Congenital Genitourinary Disease",
    "Congenital Heart Disease",
    "Coronary Heart Disease",
    "Dementia",
    "Diabetes Mellitus",
    "Epilepsy",
    "Gastric",
    "Head Injury",
    "Hearing Disabilities",
    "Heart Failure",
    "Hepatitis",
    "Hypercholesterolemia",
    "Hypertension",
    "Immunosuppressed",
    "Ischaemic Heart Disease",
    "Kidney Stone",
    "Learning Disabilities",
    "Leukemia",
    "Long term steroid therapy",
    "Mental illness",
    "Obese",
    "Pregnant",
    "Pre-existing skin condition",
    "Stroke",
    "Surgical History",
    "Systemic Lupus Erythematosus (SLE)",
    "Tuberculosis",
    "Valvular Heart Disease",
    "Age > 60",
    "Others"
  ];

  // To track which conditions are selected
  List<String> selectedConditions = [];
  bool _isSubmitting = false; // State for the loading indicator

  // Method to save the report data to Firestore
  Future<void> _saveReportToFirestore() async {
    setState(() {
      _isSubmitting = true; // Start loading
    });

    try {
      final user_id = FirebaseAuth.instance.currentUser?.uid;
      String? medicalHistory = selectedConditions.isEmpty
          ? '-'
          : selectedConditions.join(',');

      if (user_id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated.')),
        );
        setState(() {
          _isSubmitting = false; // Stop loading
        });
        return;
      }

      // Reference to Firestore collection
      CollectionReference reports =
      FirebaseFirestore.instance.collection('individual_reports');

      String indivId = 'idv${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> indivData = {
        'indivId': indivId,
        'name': widget.name,
        'birthday': widget.birthday,
        'gender': widget.gender,
        'race': widget.race,
        'ic_number': widget.ic_number,
        'passportNum': widget.passportNum,
        'phone_number': widget.phone_number,
        'address': widget.address,
        'location': widget.location,
        'medical_history': medicalHistory,
        'nationality': widget.nationality,
        'user_id': user_id,
        'timestamp': FieldValue.serverTimestamp(),
        'statusOfApproved': 'false',
      };

      // Set report data (no need for add call)
      await reports.doc(indivId).set(indivData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!')),
      );

      // Navigate back to the previous screen (ReportIndividualScreen)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
            (Route<dynamic> route) => false, // This will remove all the previous routes
      );

    } catch (e) {
      print("Error saving report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting report.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Stop loading
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor, // Change to your desired color
        title: const Text('Medical History Report'),
      ),
      body: Stack(
        children: [
          Container(
            color: kScaffoldColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your Medical Conditions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: medicalConditions.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(medicalConditions[index]),
                          value: selectedConditions.contains(medicalConditions[index]),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedConditions.add(medicalConditions[index]);
                              } else {
                                selectedConditions.remove(medicalConditions[index]);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveReportToFirestore,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: kWeatherTextColor, // Set the color of the text
                      ), // Disable button when submitting
                      child: _isSubmitting
                          ? CircularProgressIndicator() // Show loading indicator
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent background
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
  }
}
