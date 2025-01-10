import 'dart:async';

import 'package:flood_management_system/component/buildCard.dart';
import 'package:flood_management_system/component/buildDropDown.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flood_management_system/screens/report_medical_history.dart';

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

class ReportIndividualManualScreen extends StatefulWidget {
  static String id = 'report_individual_manual_screen';

  const ReportIndividualManualScreen({super.key});

  @override
  State<ReportIndividualManualScreen> createState() => _ReportIndividualManualScreenState();
}

class _ReportIndividualManualScreenState extends State<ReportIndividualManualScreen> {
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
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  String _output = '';
  bool _isLocationButtonDisabled = false;
  bool _isLoading = false; //to check whether get all the location details

  //form
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  String? _selectedRace;
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _icNumberController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _nationalityController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
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
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
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
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Manual Report",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      body: Container(
        color: kScaffoldColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20.0),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildCard(
                          icon: Icons.person,
                          label: 'Name',
                          hint:'Full name in IC',
                          controller: _nameController,
                          validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16.0),

                        buildCard(
                          icon: Icons.calendar_today,
                          label: 'Birthday',
                          hint:'DD-MM-YYYY',
                          controller: _birthdayController,
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
                              _birthdayController.text = formattedDate;
                            }
                          },
                          validator: (value) => value?.isEmpty ?? true ? 'Please pick your birthday' : null,
                        ),
                        const SizedBox(height: 16.0),

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
                        const SizedBox(height: 16.0),

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
                        const SizedBox(height: 16.0),

                        buildCard(
                          icon: Icons.credit_card,
                          label: 'IC Number',
                          hint:'XXXXXX-YY-ZZZZ',
                          controller: _icNumberController,
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty ?? true ? 'Please enter your IC number' : null,
                        ),

                        const SizedBox(height: 16.0),
                        buildCard(
                          icon: Icons.card_travel,
                          label: 'Nationality',
                          hint:'',
                          controller: _nationalityController,
                          validator: (value) => value?.isEmpty ?? true ? 'Please enter your nationality' : null,
                        ),

                        const SizedBox(height: 16.0),
                        buildCard(
                          icon: Icons.card_travel,
                          label: 'Passport Number',
                          hint:'If you are foreign',
                          controller: _passportNumberController,
                        ),
                        const SizedBox(height: 16.0),

                        buildCard(
                          icon: Icons.phone,
                          label: 'Phone Number',
                          hint:'',
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
                        ),
                        const SizedBox(height: 16.0),

                        buildCard(
                          icon: Icons.home,
                          label: 'Home Address',
                          hint:'',
                          controller: _addressController,
                          maxLines: 3,
                          validator: (value) => value?.isEmpty ?? true ? 'Please enter your address' : null,
                        ),
                        const SizedBox(height: 16.0),

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
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: _isLoading // CircularProgressIndicator if loading
                                      ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(kGradientColorTwo),
                                  )
                                      : TextFormField(
                                    controller: _locationController,
                                    decoration: const InputDecoration(
                                      labelText: 'Current Location',
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

                        const SizedBox(height: 24.0),

                        ElevatedButton(
                          onPressed: () {
                            // Validate form first
                            if (_formKey.currentState?.validate() ?? false) {
                              // Perform custom validations

                              // Capitalize name and remove special characters
                              String name = _nameController.text;
                              RegExp regExp = RegExp(r'[^a-zA-Z\s]');
                              if (regExp.hasMatch(name)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Name cannot contain special characters")),
                                );
                                return;
                              }
                              name = name.toUpperCase();

                              final birthday = _birthdayController.text;
                              final ic_number = _icNumberController.text.replaceAll('-', '');  // Remove hyphens from IC number
                              final phone_number = _phoneNumberController.text;
                              final address = _addressController.text;
                              final location = _locationController.text;
                              final passportNum = _passportNumberController.text.isEmpty ? '-' : _passportNumberController.text;
                              final nationality = _nationalityController.text;


                              // Check if the birthday matches the IC first 6 digits
                              final icBirthday = ic_number.substring(0, 6); // First 6 digits of IC number
                              final birthDateParts = birthday.split('/');
                              if (birthDateParts.length == 3) {
                                final formattedBirthday =
                                    '${birthDateParts[2].substring(2)}${birthDateParts[1].padLeft(2, '0')}${birthDateParts[0].padLeft(2, '0')}';// DDMMYY
                                if (icBirthday != formattedBirthday) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Birthday does not match IC number")),
                                  );
                                  return;
                                }
                              }

                              // Print all values (or send them to another screen or API)
                              print('Name: $name');
                              print('Birthday: $birthday');
                              print('IC Number: $ic_number');
                              print('Phone Number: $phone_number');
                              print('Address: $address');
                              print('Location: $location');
                              print('Nationality: $nationality');

                              // Proceed to next screen if validation passes
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportMedicalHistoryScreen(
                                    name: name,
                                    birthday: birthday,
                                    gender: _selectedGender,
                                    race: _selectedRace,
                                    ic_number: ic_number,
                                    passportNum: passportNum,
                                    phone_number: phone_number,
                                    address: address,
                                    location: location,
                                    nationality:nationality,
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
                        )

                      ],
                    ),
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
    _locationController.dispose();
    _nameController.dispose();
    _birthdayController.dispose();
    _icNumberController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }
}
