import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_management_system/model/ngo.dart';
import 'ngo_details_screen.dart'; // Import the details screen

class NgoScreen extends StatefulWidget {
  static String id = 'ngo_screen';
  @override
  _NgoScreenState createState() => _NgoScreenState();
}

class _NgoScreenState extends State<NgoScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Predefined work areas and locations
  final List<String> workAreas = [
    'Arts n Heritage', 'Poverty Alleviation', 'Specific Diseases', 'Health',
    'Housing', 'Vulnerable Groups', 'Development', 'Religion', 'Education and Training',
    'Rights', 'Environment and Climate', 'Other Societal Benefits'
  ];

  final List<String> locations = [
    'Kluang', 'Segamat', 'Iskandar Puteri', 'Johor Bahru', 'Batu Pahat', 'Pontian'
  ];

  String? selectedWorkArea;
  String? selectedLocation;

  Future<List<Ngo>> _fetchNgos() async {
    List<Ngo> ngos = [];
    try {
      print('Fetching NGOs from Firestore...');
      final querySnapshot = await db.collection("ngos").get();
      print('Query snapshot: ${querySnapshot.docs.length} documents found');

      for (var docSnapshot in querySnapshot.docs) {
        print('${docSnapshot.id} => ${docSnapshot.data()}');
        ngos.add(
          Ngo.fromFirestore(docSnapshot),
        );
      }
    } catch (e) {
      print('Error fetching NGOs: $e');
    }
    return ngos;
  }

  // Apply filters based on selected work area and location
  List<Ngo> _filterNgos(List<Ngo> ngos) {
    return ngos.where((ngo) {
      final matchesWorkArea = selectedWorkArea == null || ngo.workAreas.contains(selectedWorkArea);
      final matchesLocation = selectedLocation == null || ngo.location == selectedLocation;
      return matchesWorkArea && matchesLocation;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "NGOs List",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      body: Container(
        color: kScaffoldColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Work Area Filter Dropdown with Expanded for equal flex
                  Expanded(
                    flex: 1,
                    child: DropdownButton<String>(
                      value: selectedWorkArea,
                      hint: Text('Select Work Area'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedWorkArea = newValue;
                        });
                      },
                      isExpanded: true, // Ensures the dropdown takes full width
                      items: workAreas.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 10), // Add some space between the two dropdowns
                  // Location Filter Dropdown with Expanded for equal flex
                  Expanded(
                    flex: 1,
                    child: DropdownButton<String>(
                      value: selectedLocation,
                      hint: Text('Select Location'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedLocation = newValue;
                        });
                      },
                      isExpanded: true, // Ensures the dropdown takes full width
                      items: locations.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Ngo>>(
                future: _fetchNgos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No NGOs found.'));
                  } else {
                    final ngos = snapshot.data!;
                    final filteredNgos = _filterNgos(ngos);

                    return ListView.builder(
                      itemCount: filteredNgos.length,
                      itemBuilder: (context, index) {
                        final ngo = filteredNgos[index];
                        return InkWell(
                          onTap: () {
                            // Navigate to the details screen when tapping the NGO card
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NgoDetailsScreen(ngo: ngo),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(10),
                            color: kScaffoldColor, // Card background color
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ngo.ngoName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Location:',
                                        style: TextStyle(color: Colors.grey), // Grey color for title
                                      ),
                                      Expanded(
                                        child: Text(
                                          ngo.location,
                                          style: TextStyle(color: kButtonTextColor), // kButtonTextColor for value
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Country:',
                                        style: TextStyle(color: Colors.grey), // Grey color for title
                                      ),
                                      Expanded(
                                        child: Text(
                                          ngo.country,
                                          style: TextStyle(color: kButtonTextColor), // kButtonTextColor for value
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Work Areas:',
                                        style: TextStyle(color: Colors.grey), // Grey color for title
                                      ),
                                      Expanded(
                                        child: Text(
                                          ngo.workAreas.join(', '),
                                          style: TextStyle(color: kButtonTextColor), // kButtonTextColor for value
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
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
    );
  }
}
