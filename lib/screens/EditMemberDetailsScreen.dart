import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_management_system/component/buildDropDown.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flood_management_system/component/buildCard.dart';
import 'package:flood_management_system/model/member.dart';
import 'package:flutter/material.dart';

class EditMemberDetailsScreen extends StatefulWidget {
  final Member member;

  const EditMemberDetailsScreen({super.key, required this.member});

  @override
  _EditMemberDetailsScreenState createState() =>
      _EditMemberDetailsScreenState();
}

class _EditMemberDetailsScreenState extends State<EditMemberDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _genders = [
    'Male',
    'Female',
    'Other'
  ];

  final List<String> _races = [
    'Malay',
    'Chinese',
    'Indian',
    'Other'
  ];

  String? _selectedGender;
  String? _selectedRace;

  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  late TextEditingController _icNumberController;
  late TextEditingController _medicalHistoryController;
  late TextEditingController _nationalityController;
  late TextEditingController _raceController;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.member.gender;
    _selectedRace =  widget.member.race;
    _nameController = TextEditingController(text: widget.member.name);
    _positionController = TextEditingController(text: widget.member.position);
    _phoneNumberController =TextEditingController(text: widget.member.phoneNumber);
    _addressController = TextEditingController(text: widget.member.address);
    _genderController = TextEditingController(text: widget.member.gender);
    _icNumberController = TextEditingController(text: widget.member.icNumber);
    _medicalHistoryController =
        TextEditingController(text: widget.member.medical_history ?? '');
    _nationalityController =
        TextEditingController(text: widget.member.nationality);
    _raceController = TextEditingController(text: widget.member.race ?? '');
  }

  Future<void> _updateMemberDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('member_details')
            .doc(widget.member.member_id)
            .update({
          'name': _nameController.text,
          'position': _positionController.text,
          'phoneNumber': _phoneNumberController.text,
          'address': _addressController.text,
          'gender': _genderController.text,
          'icNumber': _icNumberController.text,
          'medicalHistory': _medicalHistoryController.text,
          'nationality': _nationalityController.text,
          'race': _raceController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully!')),
        );

        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text("Edit Details"),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: kScaffoldColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCard(
                icon: Icons.person,
                label: 'Name',
                hint: 'Enter name',
                controller: _nameController,
                validator: (value) =>
                value!.isEmpty ? 'Name is required' : null,
              ),
              buildCard(
                icon: Icons.work,
                label: 'Position',
                hint: 'Enter position',
                controller: _positionController,
                validator: (value) =>
                value!.isEmpty ? 'Position is required' : null,
              ),
              buildCard(
                icon: Icons.phone,
                label: 'Phone Number',
                hint: 'Enter phone number',
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty
                    ? 'Phone number is required'
                    : null,
              ),
              buildCard(
                icon: Icons.home,
                label: 'Address',
                hint: 'Enter address',
                controller: _addressController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
              buildDropdownCard(
                icon: Icons.accessibility,
                label: 'Gender',
                value: _selectedGender,
                items: _genders,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              buildCard(
                icon: Icons.credit_card,
                label: 'IC Number',
                hint: 'Enter IC number',
                controller: _icNumberController,
              ),
              buildCard(
                icon: Icons.health_and_safety,
                label: 'Medical History',
                hint: 'Enter medical history',
                controller: _medicalHistoryController,
              ),
              buildCard(
                icon: Icons.flag,
                label: 'Nationality',
                hint: 'Enter nationality',
                controller: _nationalityController,
              ),
              buildDropdownCard(
                icon: Icons.group,
                label: 'Race',
                value: _selectedRace,
                items: _races,
                onChanged: (value) {
                  setState(() {
                    _selectedRace = value;
                  });
                },
                validator: (value) => value == null ? 'Please select your race' : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateMemberDetails,
                  child: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: kWeatherTextColor, // Set the color of the text
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
