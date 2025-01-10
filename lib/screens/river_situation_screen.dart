import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_management_system/model/river.dart';

class RiverSituationScreen extends StatefulWidget {
  static String id = 'river_situation_screen';

  const RiverSituationScreen({Key? key}) : super(key: key);

  @override
  _RiverSituationScreenState createState() => _RiverSituationScreenState();
}

class _RiverSituationScreenState extends State<RiverSituationScreen> {
  // Districts list and selected district state
  final List<String> districtList = [
    "Batu Pahat", "Johor Bahru", "Kluang", "Kota Tinggi", "Kulai",
    "Mersing", "Muar", "Pontian", "Segamat", "Tangkak"
  ];
  String selectedDistrict = "Batu Pahat"; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "River Situations",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      backgroundColor: kScaffoldColor,
      body: Column(
        children: [
          // Positioned DropdownButton to the right
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align the dropdown to the right
              children: [
                DropdownButton<String>(
                  value: selectedDistrict,
                  icon: const Icon(Icons.arrow_downward, color: kButtonTextColor),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: kButtonTextColor),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDistrict = newValue!;
                    });
                  },
                  items: districtList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('infobanjir')
                  .where('district', isEqualTo: selectedDistrict) // Filter by selected district
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No data available.'));
                }

                // Map Firestore documents to River objects
                final rivers = snapshot.data!.docs.map((doc) => River.fromFirestore(doc)).toList();

                return ListView.builder(
                  itemCount: rivers.length,
                  itemBuilder: (context, index) {
                    final river = rivers[index];

                    // Determine the color for the `wl` based on thresholds
                    final wlColor = _getWaterLevelColor(river.wl, river.normal, river.alert, river.warning, river.danger);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RiverDetailsScreen(river: river),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: kAppIconBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Main Basin: ${river.mainBasin}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text('Sub River Basin: ${river.subRiverBasin}'),
                              Row(
                                children: [
                                  const Text('Water Level: ', style: TextStyle(fontWeight: FontWeight.w100)),
                                  Text(
                                    '${river.wl} m',
                                    style: TextStyle(color: wlColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getWaterLevelColor(String wlString, String normalString, String alertString, String warningString, String dangerString) {
    // Parse strings to doubles
    final wl = double.tryParse(wlString) ?? 0.0;
    final normal = double.tryParse(normalString) ?? 0.0;
    final alert = double.tryParse(alertString) ?? 0.0;
    final warning = double.tryParse(warningString) ?? 0.0;
    final danger = double.tryParse(dangerString) ?? 0.0;

    if (wl >= danger) {
      return Colors.red; // Danger
    } else if (wl >= warning) {
      return Colors.orange; // Warning
    } else if (wl >= alert) {
      return Colors.yellow; // Alert
    } else if (wl >= normal) {
      return Colors.lightGreenAccent; // Normal
    } else {
      return Colors.blue; // Below Normal
    }
  }
}

class RiverDetailsScreen extends StatelessWidget {
  final River river;

  const RiverDetailsScreen({Key? key, required this.river}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "River Details",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      backgroundColor: kScaffoldColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: kScaffoldColor,
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.numbers, "No", river.no),
                _buildDetailRow(Icons.location_on, "Station ID", river.stationId),
                _buildDetailRow(Icons.label, "Station Name", river.stationName),
                _buildDetailRow(Icons.map, "District", river.district),
                _buildDetailRow(Icons.water, "Main Basin", river.mainBasin),
                _buildDetailRow(Icons.water_drop, "Sub River Basin", river.subRiverBasin),
                _buildDetailRow(Icons.access_time, "Last Updated", river.lastUpdated),
                _buildDetailRow(Icons.water_drop, "Water Level", "${river.wl} m"),
                _buildDetailRow(Icons.check, "Normal Level", "${river.normal} m"),
                _buildDetailRow(Icons.warning, "Alert Level", "${river.alert} m"),
                _buildDetailRow(Icons.report_problem, "Warning Level", "${river.warning} m"),
                _buildDetailRow(Icons.dangerous, "Danger Level", "${river.danger} m"),
                _buildDetailRow(Icons.link, "Water Level Link", river.wlLink),
                _buildDetailRow(Icons.calendar_today, "Timestamp", river.timestamp.toDate().toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kButtonTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label:\n",
                    style: kTitleStyle5,
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
