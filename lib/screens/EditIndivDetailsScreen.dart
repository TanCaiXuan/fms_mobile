import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/model/individual.dart';
import 'package:flood_management_system/component/constant.dart';

class EditIndivDetailsScreen extends StatefulWidget {
  final Individual individual;

  const EditIndivDetailsScreen({super.key, required this.individual});

  @override
  _EditIndivDetailsScreenState createState() =>
      _EditIndivDetailsScreenState();
}

class _EditIndivDetailsScreenState extends State<EditIndivDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _icNumberController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  late TextEditingController _raceController;
  late TextEditingController _nationalityController;
  late TextEditingController _birthdayController;
  late TextEditingController _passportNumController;
  late TextEditingController _medicalHistoryController;

  @override
  void initState() {
    super.initState();

    // Initializing the text controllers with current data from individual
    _nameController = TextEditingController(text: widget.individual.name);
    _icNumberController = TextEditingController(text: widget.individual.ic_number);
    _phoneNumberController = TextEditingController(text: widget.individual.phone_number);
    _addressController = TextEditingController(text: widget.individual.address);
    _genderController = TextEditingController(text: widget.individual.gender);
    _raceController = TextEditingController(text: widget.individual.race ?? '');
    _nationalityController = TextEditingController(text: widget.individual.nationality);
    _birthdayController = TextEditingController(text: widget.individual.birthday);
    _passportNumController = TextEditingController(text: widget.individual.passportNum ?? '');
    _medicalHistoryController = TextEditingController(text: widget.individual.medical_history ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icNumberController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _raceController.dispose();
    _nationalityController.dispose();
    _birthdayController.dispose();
    _passportNumController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _updateIndividual() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Prepare data for updating the individual
        final updatedIndividual = Individual(
          indivId: widget.individual.indivId,
          name: _nameController.text,
          ic_number: _icNumberController.text,
          phone_number: _phoneNumberController.text,
          address: _addressController.text,
          gender: _genderController.text,
          race: _raceController.text,
          nationality: _nationalityController.text,
          birthday: _birthdayController.text,
          passportNum: _passportNumController.text,
          medical_history: _medicalHistoryController.text,
          statusOfApproved: widget.individual.statusOfApproved,
          timestamp: widget.individual.timestamp,
          user_id: widget.individual.user_id,
        );

        // Update the data in Firestore
        await FirebaseFirestore.instance
            .collection('individual_reports')
            .doc(widget.individual.indivId)
            .update(updatedIndividual.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Individual details updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        print("Error updating individual details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating individual details')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text("Edit Individual Details"),
        centerTitle: true,
      ),
      backgroundColor: kScaffoldColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', _nameController),
                _buildTextField('IC Number', _icNumberController),
                _buildTextField('Phone Number', _phoneNumberController),
                _buildTextField('Address', _addressController),
                _buildTextField('Gender', _genderController),
                _buildTextField('Race', _raceController),
                _buildTextField('Nationality', _nationalityController),
                _buildTextField('Birthday', _birthdayController),
                _buildTextField('Passport Number', _passportNumController),
                _buildTextField('Medical History', _medicalHistoryController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateIndividual,
                  child: const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: kWeatherTextColor, // Set text color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields for the form
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
        maxLines: label == 'Address' || label == 'Medical History' ? null : 1, // Allow multi-line input for 'Address' and 'Medical History'
        keyboardType: label == 'Phone Number' ? TextInputType.phone : TextInputType.text,
      ),
    );
  }

}
