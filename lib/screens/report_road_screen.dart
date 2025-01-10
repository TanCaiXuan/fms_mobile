import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

class ReportRoadScreen extends StatefulWidget {
  static String id = 'report_road_screen';

  const ReportRoadScreen({super.key});

  @override
  State<ReportRoadScreen> createState() => _ReportRoadScreenState();
}

class _ReportRoadScreenState extends State<ReportRoadScreen> {
  final _formKey = GlobalKey<FormState>();
  //reason
  String? _selectedReason;
  final List<String> _reasons = [
    'Heavy Rain',
    'River Arise',
    'Blocked Drain',
    'Other'
  ];

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


  //image
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  // Create a storage reference from our app
  final storageRef = FirebaseStorage.instance.ref();
  String downloadUrl ="";
  // Generate a unique file name
  String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
  // Get the current user's UID (assumes the user is authenticated)
  String? user_id = FirebaseAuth.instance.currentUser?.uid;

  // form
  bool _isSubmitting = false;

  @override
  void initState() {
    _addressController.text = 'Skudai Highway';
    _latitudeController.text = '1.5163932791813362';
    _longitudeController.text = '103.68381250412392';
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

 // image
  Future<void> _pickImage() async {
    try {
      XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = pickedFile; // Store the picked XFile
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error picking image.')));
    }
  }


  // Compress image for faster upload
  Future<File> compressImage(File imageFile) async {
    final result = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 800, // Specify the minimum width
      minHeight: 800, // Specify the minimum height
      quality: 90, // Quality percentage (lower value = higher compression)
      rotate: 0, // Rotation if needed
    );

    if (result == null) {
      throw Exception("Failed to compress image.");
    }

    // Save the compressed image
    final compressedFile = File(imageFile.absolute.path)..writeAsBytesSync(result);
    return compressedFile;
  }

  Future<void> uploadFile() async {
    if (_image == null) {
      print("No image selected to upload.");
      return;
    }

    File file = File(_image!.path);

    // Check if the file exists
    if (!await file.exists()) {
      print("File not found: ${file.path}");
      return;
    }

    try {
      // Compress the selected image
      File compressedImage = await compressImage(file);

      // Generate a unique file name
      String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
      final imageRef = FirebaseStorage.instance.ref().child("images/road_$uniqueName.jpg");

      // Upload the file to Firebase Storage
      await imageRef.putFile(compressedImage);

      // Successfully uploaded, now fetch the download URL
      downloadUrl = await imageRef.getDownloadURL();

      // Set the download URL (for further use)
      print("Image uploaded successfully. Download URL: $downloadUrl");

      downloadUrl = downloadUrl; // Store the download URL
    } on FirebaseException catch (e) {
      print("Upload failed: ${e.message}");
    } catch (e) {
      print("Error during file upload: $e");
    }
  }



// Method to handle form submission
  Future<void> _submitReport() async {
    // Start loading indicator
    setState(() {
      _isSubmitting = true;
    });

    // Validate the form before proceeding
    if (_formKey.currentState?.validate() ?? false) {
      final reason = _selectedReason;
      final location = _locationController.text;

      // Check if the required fields are filled in before proceeding
      if (reason == null || location.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all required fields.'))
        );
        return;
      }

      // Upload the image and get the download URL
      await uploadFile(); // This method should set the downloadUrl

      // Check if the download URL is available
      if (downloadUrl.isNotEmpty){
        // Save the report to Firestore if the image URL is available
        await _saveReportToFirestore(reason, location, downloadUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image URL is missing.'))
        );
      }
    }
  }


// Method to save the report data to Firestore
  Future<void> _saveReportToFirestore(String reason, String location, String downloadUrl) async {
    try {

      if (user_id == null) {
        // Handle case when the user is not authenticated (if necessary)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated.')));
        return;
      }

      // Reference to Firestore collection
      CollectionReference reports = FirebaseFirestore.instance.collection('road_reports');
      String road_rep_id = 'road_rep${DateTime.now().millisecondsSinceEpoch}';



      Map<String, dynamic> roadData = {
        'road_rep_id':road_rep_id,
        'reason': reason,
        'location': location,
        'image_url': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': user_id,
        'statusOfApproved':'false'
      };

      await reports
          .doc(road_rep_id)
          .set(roadData);

      // Clear the form after submission
      _formKey.currentState?.reset();
      setState(() {
        _image = null; // Reset the image
        _selectedReason = null; // Clear the reason
        _locationController.clear(); // Clear the location field
        _isSubmitting = false; // Stop loading indicator
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully!')));
    } catch (e) {
      print("Error saving report: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error submitting report.')));
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Road Report",
          style: TextStyle(color: kButtonTextColor),
        ),

      ),
      body: Stack(
        children: [
          SingleChildScrollView( // Scrollable form
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form( // Wrap form fields inside a Form widget
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20.0), // Space at the top

                    // Reason card
                    Card(
                      elevation: 2.0,
                      color: kScaffoldColor,
                      shadowColor: kLightGreyColor,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.event, color: kAppBarColor),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: SizedBox(
                                height: 60.0, // Fixed height for consistency
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Reason',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: kScaffoldColor,
                                  ),
                                  dropdownColor: kScaffoldColor,
                                  value: _selectedReason,
                                  items: _reasons.map((reason) {
                                    return DropdownMenuItem<String>(
                                      value: reason,
                                      child: Text(
                                        reason,
                                        style: const TextStyle(color: kButtonTextColor),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedReason = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a reason';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Location card
                    Card(
                      elevation: 2.0,
                      color: kScaffoldColor,
                      shadowColor: kLightGreyColor,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: kAppBarColor),
                            const SizedBox(width: 16.0),
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

                    // Image picker card
                    Card(
                      elevation: 2.0,
                      color: kScaffoldColor,
                      shadowColor: kLightGreyColor,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt, color: kAppBarColor),
                            const SizedBox(width: 16.0),
                            ElevatedButton(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: kButtonTextColor,
                                backgroundColor: kAppBarColor, // Set the color of the text
                              ),
                              child: const Text('Take a Picture for proving'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Display picked image if available
                    _image != null
                        ? Image.file(File(_image!.path)) // Convert XFile to File for display
                        : const Text('No image selected'),

                    // Submit button
                    ElevatedButton(
                      onPressed: () async {
                        await _submitReport();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: kWeatherTextColor, // Set the color of the text
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading spinner overlay
          if (_isSubmitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent background
                child: Center(
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
    _locationController.dispose();
    super.dispose();
  }
}


