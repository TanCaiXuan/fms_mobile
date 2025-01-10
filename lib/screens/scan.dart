import 'dart:io';
import 'package:flood_management_system/screens/report_indiv_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; 
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class Scan extends StatefulWidget {
  static String id = 'scan';
  const Scan({super.key});

  @override
  ScanState createState() => ScanState();
}

class ScanState extends State<Scan> {
  String result = ''; // This will hold the scanned text result
  File? image; // This will hold the selected image file
  ImagePicker? imagePicker; // ImagePicker for picking image from gallery or camera
  DocumentScanner? _documentScanner;
  DocumentScanningResult? _scanResult; // Updated to hold the document scanning result

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker(); 
  }

  // Pick image from the gallery
  Future<void> pickImageFromGallery() async {
    final pickedFile = await imagePicker!.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      // After selecting image, scan it
      await performTextRecognize(image!); 
    }
  }

  // Pick image from the camera
  void pickImageFromCamera(DocumentFormat format) async {
    try {
      setState(() {
        _scanResult = null; // Reset the scanning result
      });

      _documentScanner?.close();
      _documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: format,
          mode: ScannerMode.full,
          isGalleryImport: false,
          pageLimit: 1,
        ),
      );
      _scanResult = await _documentScanner?.scanDocument(); // Perform document scanning
      print('Scan result: $_scanResult');
      setState(() {}); // Refresh UI

      // Perform text recognition on the scanned document
      if (_scanResult != null && _scanResult!.images.isNotEmpty) {
        await performTextRecognize(File(_scanResult!.images.first)); // Perform text recognition on the first scanned image
      }
    } catch (e) {
      print('Error scanning document: $e');
    }
  }

  Future<void> performTextRecognize(File imageFile) async {
    final InputImage inputImage = InputImage.fromFile(imageFile); // Convert the image to InputImage format
    final TextRecognizer textRecognizer = TextRecognizer(); // Initialize TextRecognizer

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage); // Process the image

      String text = recognizedText.text;
      Map<String, String> details = {};

      // Extract IC number
      RegExp icRegex = RegExp(r'\d{6}-\d{2}-\d{4}');
      Match? icMatch = icRegex.firstMatch(text);
      String icNumber = '';
      if (icMatch != null) {
        icNumber = icMatch.group(0)!.replaceAll('-', ''); // Remove hyphens from IC number
        details['ic_number'] = icNumber;
      } else {
        print("No match found for IC.");
      }

      // Extract Name
      RegExp nameRegex = RegExp(r'-\d+\s+([A-Za-z\s]+)\s+NO\s+\d+');
      Match? nameMatch = nameRegex.firstMatch(text);
      if (nameMatch != null) {
        String name = nameMatch.group(1)!;
        details['name'] = name;
      } else {
        print("No match found for name.");
      }

      // Extract Address and State
      List<String> states = [
        "JOHOR", "KEDAH", "KELANTAN", "MELAKA", "NEGERI SEMBILAN", "PAHANG",
        "PULAU PINANG", "PERAK", "PERLIS", "SELANGOR", "TERENGGANU", "SABAH",
        "SARAWAK", "WILAYAH PERSEKUTUAN"
      ];

      bool containsState = states.any((state) => text.contains('NO') && text.contains(state));
      if (containsState) {
        RegExp locationRegex = RegExp(r'NO\s+\d+\s+([A-Za-z\s0-9\/]+)\s+\d{5}\s+([A-Za-z\s]+)');
        Match? locationMatch = locationRegex.firstMatch(text);
        if (locationMatch != null) {
          String address = locationMatch.group(0)!;
          details['address'] = address;
        } else {
          print("No match found for address and state.");
        }
      }

      // Extract Gender
      if (text.contains('PEREMPUAN')) {
        details['gender'] = "Female";
      } else {
        details['gender'] = "Male";
      }

      // Extract birthday from IC number's first 6 digits
      String icYearStr = icNumber.substring(0, 2); 
      int icYear = int.parse(icYearStr);

      int currentYearLastTwoDigits = int.parse(DateTime.now().year.toString().substring(2, 4)); 
      String birthday;

      // Determine century based on the IC number’s year part
      if (icYear <= currentYearLastTwoDigits) {
        birthday = '20$icYearStr'; 
      } else {
        birthday = '19$icYearStr'; 
      }

      // Construct the full birthday in DD/MM/YYYY format
      birthday = '${icNumber.substring(4, 6)}/${icNumber.substring(2, 4)}/$birthday';

      // Navigate to the next screen with extracted details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportIndividualScanScreen(
            name: details['name'] ?? '',
            birthday: birthday,
            gender: details['gender'] ?? 'Male',
            ic_number: details['ic_number'] ?? '',
            address: details['address'] ?? '',
            nationality: "Malaysia",
            phone_number: '',
          ),
        ),
      );

      setState(() {
        result = recognizedText.text;
      });

    } catch (e) {
      setState(() {
        result = "Error recognizing text: $e";
      });
    } finally {
      textRecognizer.close(); // Clean up
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
        "Scan ",
        style: TextStyle(color: kButtonTextColor),
    ),
        ),
      body: Container(
        color: kScaffoldColor,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Display image or text
                image == null
                    ? const Text('No image selected.', textAlign: TextAlign.center)
                    : Image.file(image!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: pickImageFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppBarColor,
                  ),
                  child: const Text(
                    'Pick Image from Gallery',
                    style: TextStyle(color: kButtonTextColor),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => pickImageFromCamera(DocumentFormat.jpeg),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppBarColor,
                  ),
                  child: const Text(
                    'Pick Image from Camera',
                    style: TextStyle(color: kButtonTextColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Display text recognition result
                result.isEmpty
                    ? const Text(
                  'No text recognized yet.',
                  textAlign: TextAlign.center,
                )
                    : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    result,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
