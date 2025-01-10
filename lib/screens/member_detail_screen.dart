import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flood_management_system/component/buildCard.dart';

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

class MemberDetailsScreen extends StatefulWidget {

  // Constructor to pass parameters
  const MemberDetailsScreen({
    super.key,
    required this.numberOfMembers,  // Required int parameter
    required this.grpName,
  });

  final int numberOfMembers;
  final String grpName;

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  // location
  final _locationController = TextEditingController();
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;


  // long lat to location
  String _output = '';
  bool _isLocationButtonDisabled = false;
  bool _isLoading = false; //to check whether get all the location details

  // Leader Details
  final _leaderNameController = TextEditingController();
  final _leaderIcNumberController = TextEditingController();
  final _leaderAddressController = TextEditingController();
  final _leaderBirthdayController = TextEditingController();
  final _leaderPassportNumController = TextEditingController();
  final _leaderPhoneNumberController = TextEditingController();
  final _leaderNationalityController = TextEditingController();

  // Member Details
  final List<TextEditingController> _memberNameControllers = [];
  final List<TextEditingController> _memberIcControllers = [];
  final List<TextEditingController> _memberAddressControllers = [];
  final List<TextEditingController> _memberPhoneNumberControllers = [];
  final List<TextEditingController> _memberNationalityControllers = [];
  final List<TextEditingController> _memberMedicalHistoryControllers = [];
  final List<TextEditingController> _memberBirthdayControllers = [];
  final List<TextEditingController> _memberPassNumControllers = [];

  // Dropdown values
  String _selectedLeaderGender = 'Male';
  String _selectedLeaderRace = 'Malay';
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _races = ['Malay', 'Chinese', 'Indian', 'Other'];

  final List<String> _memberGenderSelections = [];
  final List<String> _memberRaceSelections = [];

  // hold current value
  bool _isSubmitting = false;  // Flag to manage loading state
  int currentScreen = 0; // Track current screen: 0 for leader, 1+ for members
  int currentMemberIndex = 0; // Track current member being input

  // medical history
  bool _hasMedicalHistoryLeader = false;
  bool _hasMedicalHistoryMember = false;
  TextEditingController _leaderMedicalHistoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMemberControllers();
    _toggleServiceStatusStream();
  }

  // location
  Future<void> _getCurrentPosition() async {
    setState(() {
      _isLocationButtonDisabled = true; // Disable button when pressed
    });

    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      _isLocationButtonDisabled = false;
      _isLoading = false;
      return;
    }

    // Get the current position
    final position = await _geolocatorPlatform.getCurrentPosition();

    // Use the latitude and longitude from the current position
    final latitude = position.latitude;
    final longitude = position.longitude;

    // Fetch placemarks based on the current coordinates
    placemarkFromCoordinates(latitude, longitude).then((placemarks) {
      var output = 'No results found.';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];

        // Populate dictionary with placemark details
        var locationDetails = {
          'House Number': placemark.subThoroughfare ?? '', // House number
          'Thoroughfare': placemark.thoroughfare ?? '', //Jalan
          'Sublocality': placemark.subLocality ?? '', // Taman
          'Locality': placemark.locality ?? '', //district
          'Postal code': placemark.postalCode ?? '', // postal code
          'ISO Country Code': placemark.isoCountryCode ?? '',
        };

        // Convert dictionary to a string representation for display
        output = locationDetails.entries
            .map((entry) => entry.value)
            .join(',\n');
      }

      setState(() {
        _output = output;
        _locationController.text = _output;
        _isLocationButtonDisabled = false;
        _isLoading = false; // Hide CircularProgressIndicator
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false; // Hide CircularProgressIndicator on error
      });
      // Handle error if location fetching fails
      print("Error fetching location: $error");
    });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updatePositionList(
        _PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        _updatePositionList(
          _PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        _PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(
      _PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));
    setState(() {});
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription!.isPaused);

  Color _determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }

  void _toggleServiceStatusStream() {
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream = _geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
            _serviceStatusStreamSubscription?.cancel();
            _serviceStatusStreamSubscription = null;
          }).listen((serviceStatus) {
            String serviceStatusValue;
            if (serviceStatus == ServiceStatus.enabled) {
              if (positionStreamStarted) {
                _toggleListening();
              }
              serviceStatusValue = 'enabled';
            } else {
              if (_positionStreamSubscription != null) {
                setState(() {
                  _positionStreamSubscription?.cancel();
                  _positionStreamSubscription = null;
                  _updatePositionList(
                      _PositionItemType.log, 'Position Stream has been canceled');
                });
              }
              serviceStatusValue = 'disabled';
            }
            _updatePositionList(
              _PositionItemType.log,
              'Location service has been $serviceStatusValue',
            );
          });
    }
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) => _updatePositionList(
        _PositionItemType.position,
        position.toString(),
      ));
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }

      _updatePositionList(
        _PositionItemType.log,
        'Listening for position updates $statusDisplayValue',
      );
    });
  }

  void _initializeMemberControllers() {
    for (int i = 0; i < widget.numberOfMembers; i++) {
      _memberNameControllers.add(TextEditingController());
      _memberIcControllers.add(TextEditingController());
      _memberAddressControllers.add(TextEditingController());
      _memberPhoneNumberControllers.add(TextEditingController());
      _memberMedicalHistoryControllers.add(TextEditingController());
      _memberNationalityControllers.add(TextEditingController());
      _memberBirthdayControllers.add(TextEditingController());
      _memberPassNumControllers.add(TextEditingController());
      _memberGenderSelections.add('Male');
      _memberRaceSelections.add('Malay');
    }
  }

  void submitDetails() async {
    setState(() {
      _isSubmitting = true;  // Show loading spinner
    });

    // Create references to Firestore collections
    CollectionReference memberDetails = FirebaseFirestore.instance.collection('member_details');

    // Generate unique group ID (grp_id) using the format "Grp{uniqueNum}"
    String grpId = 'Grp${DateTime.now().millisecondsSinceEpoch}';

    try {
      final user_id = FirebaseAuth.instance.currentUser?.uid;
      List<String> memberIds = [];
      if (user_id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated.')),
        );
        setState(() {
          _isSubmitting = false; // Stop loading if no user is authenticated
        });
        return;
      }

      // Save leader's details
      String leaderId = 'Lead${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> leaderData = {
        'member_id': leaderId,
        'grp_id': grpId,
        'name': _leaderNameController.text,
        'gender': _selectedLeaderGender,
        'race': _selectedLeaderRace,
        'ic_number': _leaderIcNumberController.text,
        'address': _leaderAddressController.text,
        'birthday': _leaderBirthdayController.text,
        'phone_number': _leaderPhoneNumberController.text,
        'passportNum': _leaderPassportNumController.text.isEmpty ? '-' : _leaderPassportNumController.text,
        'nationality': _leaderNationalityController.text,
        'user_id': user_id,
        'timestamp': FieldValue.serverTimestamp(),
        'position': 'leader',
      };


      if (_hasMedicalHistoryLeader) {
        leaderData['medical_history'] = _leaderMedicalHistoryController.text;
      }
      else {
        leaderData['medical_history'] = '-';
      }

      // Save the leader's data
      await memberDetails
          .doc(leaderId)
          .set(leaderData);

      // Save members' details in member_details collection
      for (int i = 0; i < widget.numberOfMembers; i++) {
        // Generate a custom member ID
        String memberId = 'mbr${DateTime.now().millisecondsSinceEpoch}${i}';

        // Create a map to hold member data
        Map<String, dynamic> memberData = {
          'member_id': memberId,
          'grp_id': grpId,
          'name': _memberNameControllers[i].text,
          'gender': _memberGenderSelections[i],
          'race': _memberRaceSelections[i],
          'birthday': _memberBirthdayControllers[i].text,
          'ic_number': _memberIcControllers[i].text,
          'passportNum': _memberPassNumControllers[i].text.isEmpty ? '-' : _memberPassNumControllers[i].text,
          'address': _memberAddressControllers[i].text,
          'phone_number': _memberPhoneNumberControllers[i].text,
          'nationality': _memberNationalityControllers[i].text,
          'user_id': user_id,
          'timestamp': FieldValue.serverTimestamp(),
          'position': 'member',
        };

        // Add medical history if applicable
        if (_hasMedicalHistoryMember) {
          memberData['medical_history'] = _memberMedicalHistoryControllers[i].text;
        }
        else {
          memberData['medical_history'] = '-';
        }

        // Add the member to Firestore with the custom memberId
        await memberDetails
            .doc(memberId) // Set the custom document ID
            .set(memberData);

        // Add the memberId to the list
        memberIds.add(memberId);
      }

      // Save group information
      await FirebaseFirestore.instance.collection('groups').doc(grpId).set({
        'grp_id': grpId,
        'grp_name': widget.grpName,
        'leader_id': leaderId,
        'member_ids': memberIds,
        'user_id': user_id,
        'location': _locationController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'statusOfApproved': 'false',
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Member Details Submitted!")));

      // Optionally, navigate to another screen or clear the form
      Navigator.pop(context);  // Go back to the previous screen after submission
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isSubmitting = false;  // Stop loading spinner after the operation completes
      });
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
          "Group Details",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      backgroundColor: kScaffoldColor,
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: currentScreen == 0 ? _buildLeaderInputScreen() : _buildMemberInputScreen(),
      ),
    );
  }


  Widget _buildLeaderInputScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leader Details',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: kButtonTextColor),
          ),
          const SizedBox(height: 10.0),
          _buildCard(
            icon: Icons.person,
            label: 'Leader Name',
            controller: _leaderNameController,
          ),
          const SizedBox(height: 10.0),
          _buildCard(
            icon: Icons.accessibility,
            label: 'Gender',
            child: _buildDropdown(
              value: _selectedLeaderGender,
              items: _genders,
              onChanged: (value) {
                setState(() {
                  _selectedLeaderGender = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 10.0),
          _buildCard(
            icon: Icons.credit_card,
            label: 'Leader IC Number',
            controller: _leaderIcNumberController,
          ),
          const SizedBox(height: 10.0),
          buildCard(
            icon: Icons.calendar_today,
            label: 'Birthday',
            hint:'DD-MM-YYYY',
            controller: _leaderBirthdayController,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                _leaderBirthdayController.text = formattedDate;
              }
            },
            validator: (value) => value?.isEmpty ?? true ? 'Please pick your birthday' : null,
          ),
          const SizedBox(height: 10.0),
          _buildCard(
            icon: Icons.group,
            label: 'Race',
            child: _buildDropdown(
              value: _selectedLeaderRace,
              items: _races,
              onChanged: (value) {
                setState(() {
                  _selectedLeaderRace = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 10.0),
          _buildCard(
            icon: Icons.home,
            label: 'Leader Address',
            controller: _leaderAddressController,
          ),
          const SizedBox(height: 10.0),
          _buildCard(
            icon: Icons.phone,
            label: 'Leader Phone Number',
            controller: _leaderPhoneNumberController,
          ),
          const SizedBox(height: 10.0),
          _buildCard(
            icon: Icons.flag,
            label: 'Nationality',
            controller: _leaderNationalityController,
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            color: kScaffoldColor,
            shadowColor: kLightGreyColor,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: kButtonTextColor),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _isLoading // CircularProgressIndicator if loading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kGradientColorTwo),
                    )
                        : TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null, // Allows unlimited lines
                      minLines: 1, // Minimum 1 line of text
                      keyboardType: TextInputType.multiline, // Supports multiline input
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the location';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: _isLocationButtonDisabled ? kDisabledColor : kWeatherTextColor,
                    ),
                    onPressed: _isLocationButtonDisabled ? null : _getCurrentPosition, // Disable when necessary
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),

          // Medical History Checkbox
          CheckboxListTile(
            title: const Text('Do you have any medical history?'),
            value: _hasMedicalHistoryLeader,
            onChanged: (bool? newValue) {
              setState(() {
                _hasMedicalHistoryLeader = newValue!;
              });
            },
          ),

          // Conditionally display medical history input field
          if (_hasMedicalHistoryLeader) ...[
            const SizedBox(height: 10.0),
            _buildCard(
              icon: Icons.local_hospital,
              label: 'Medical History Details',
              controller: _leaderMedicalHistoryController,
            ),
          ],

          const SizedBox(height: 10.0),

          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentScreen = 1; // Navigate to the member input screen
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kWeatherTextColor, // Set the color of the text
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMemberInputScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Member ${currentMemberIndex + 1} Details',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: kButtonTextColor),
          ),
          const SizedBox(height: 10.0),
          // Member Name Input Field
          _buildCard(
            icon: Icons.person,
            label: 'Member Name',
            controller: _memberNameControllers[currentMemberIndex],
          ),
          const SizedBox(height: 10.0),
          // Gender Dropdown
          _buildCard(
            icon: Icons.accessibility,
            label: 'Gender',
            child: _buildDropdown(
              value: _memberGenderSelections[currentMemberIndex],
              items: _genders,
              onChanged: (value) {
                setState(() {
                  _memberGenderSelections[currentMemberIndex] = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 10.0),
          buildCard(
            icon: Icons.calendar_today,
            label: 'Birthday',
            hint: 'DD-MM-YYYY',
            controller: _memberBirthdayControllers[currentMemberIndex],
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                _memberBirthdayControllers[currentMemberIndex].text = formattedDate;
              }
            },
            validator: (value) => value?.isEmpty ?? true ? 'Please pick your birthday' : null,
          ),



          const SizedBox(height: 10.0),
          // Member IC Input Field
          _buildCard(
            icon: Icons.credit_card,
            label: 'Member IC Number',
            controller: _memberIcControllers[currentMemberIndex],
          ),

          const SizedBox(height: 16.0),
          buildCard(
            icon: Icons.card_travel,
            label: 'Passport Number',
            hint:'If you are foreign',
            controller: _memberPassNumControllers[currentMemberIndex],
          ),

          const SizedBox(height: 10.0),
          // Race Dropdown
          _buildCard(
            icon: Icons.group,
            label: 'Race',
            child: _buildDropdown(
              value: _memberRaceSelections[currentMemberIndex],
              items: _races,
              onChanged: (value) {
                setState(() {
                  _memberRaceSelections[currentMemberIndex] = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 10.0),
          // Member Address Input Field
          _buildCard(
            icon: Icons.home,
            label: 'Member Address',
            controller: _memberAddressControllers[currentMemberIndex],
          ),
          const SizedBox(height: 10.0),
          // Member Phone Number Input Field
          _buildCard(
            icon: Icons.phone,
            label: 'Member Phone Number',
            controller: _memberPhoneNumberControllers[currentMemberIndex],
          ),
          const SizedBox(height: 10.0),
          _buildCard(
            icon: Icons.flag,
            label: 'Nationality',
            controller: _memberNationalityControllers[currentMemberIndex],
          ),

                    const SizedBox(height: 10.0),
          // Medical History Checkbox
          CheckboxListTile(
            title: const Text('Do you have any medical history?'),
            value: _hasMedicalHistoryMember,
            onChanged: (bool? newValue) {
              setState(() {
                _hasMedicalHistoryMember = newValue!;
              });
            },
          ),

          // Conditionally display medical history input field
          if (_hasMedicalHistoryMember) ...[
            const SizedBox(height: 10.0),
            _buildCard(
              icon: Icons.local_hospital,
              label: 'Medical History Details',
              controller: _memberMedicalHistoryControllers[currentMemberIndex],
            ),
          ],

          // Submit or Next Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (currentMemberIndex < widget.numberOfMembers - 1) {
                  setState(() {
                    currentMemberIndex++;
                  });
                } else {
                  submitDetails(); // Submit all details when the last member's info is entered
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kWeatherTextColor,
              ),
              child: Text(
                currentMemberIndex < widget.numberOfMembers - 1 ? 'Next' : 'Submit',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    Widget? child, // Allows passing a custom widget like a dropdown
  }) {
    return Card(
      elevation: 2.0,
      color: kScaffoldColor, // Replace with your desired card color
      shadowColor: kLightGreyColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: kButtonTextColor), // Replace with your icon color
            const SizedBox(width: 10.0),
            Expanded(
              child: child ??
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()), // Customize this based on item type
        ),
      )
          .toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }



  @override
  void dispose() {
    _leaderNameController.dispose();
    _leaderIcNumberController.dispose();
    _leaderAddressController.dispose();
    _leaderPhoneNumberController.dispose();
    _leaderNationalityController.dispose();
    _leaderMedicalHistoryController.dispose();
    _leaderPassportNumController.dispose();


    for (var controller in _memberNameControllers) {
      controller.dispose();
    }

    for (var controller in _memberPassNumControllers) {
      controller.dispose();
    }
    for (var controller in _memberIcControllers) {
      controller.dispose();
    }
    for (var controller in _memberAddressControllers) {
      controller.dispose();
    }
    for (var controller in _memberPhoneNumberControllers) {
      controller.dispose();
    }
    for (var controller in _memberNationalityControllers) {
      controller.dispose();
    }

    for (var controller in _memberMedicalHistoryControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
