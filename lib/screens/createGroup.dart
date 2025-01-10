import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'member_detail_screen.dart';

class createGroupScreen extends StatefulWidget {
  static String id = 'create_group_screen';

  const createGroupScreen({super.key});

  @override
  State<createGroupScreen> createState() => _createGroupScreenState();
}

class _createGroupScreenState extends State<createGroupScreen> {
  final _groupNameController = TextEditingController();
  final _numberOfMembersController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for the form to validate inputs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create Group",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      body: Container(
        color: kScaffoldColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20.0), // Adjust the height as needed

              Expanded(
                child: Form(
                  key: _formKey, // Assign the form key
                  child: Column(
                    children: [
                      // Group Name Input Field
                      TextFormField(
                        controller: _groupNameController,
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a group name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Number of Members Input Field
                      TextFormField(
                        controller: _numberOfMembersController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Members (excluding leader)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of members';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Please enter a valid number greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Next Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Navigate to the member details page if form is valid
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemberDetailsScreen(
                                  grpName: _groupNameController.text,
                                  numberOfMembers: int.parse(_numberOfMembersController.text),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: kWeatherTextColor, // Set the color of the text
                        ),
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _numberOfMembersController.dispose();
    super.dispose();
  }
}
