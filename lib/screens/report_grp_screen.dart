import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_management_system/model/group.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flood_management_system/screens/ShowMemberDetailScreen.dart';
import 'package:flood_management_system/screens/createGroup.dart';

class ReportGroupScreen extends StatefulWidget {
  static String id = 'report_group_screen';

  const ReportGroupScreen({super.key});

  @override
  State<ReportGroupScreen> createState() => _ReportGroupScreenState();
}

class _ReportGroupScreenState extends State<ReportGroupScreen> {
  late Future<List<Group>> futureGroups;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    futureGroups = _fetchGroups();
  }

  Future<List<Group>> _fetchGroups() async {
    List<Group> groups = [];
    try {
      print('Fetching groups from Firestore...');
      final querySnapshot = await db.collection("groups").get();
      print('Query snapshot: ${querySnapshot.docs.length} documents found');

      for (var docSnapshot in querySnapshot.docs) {
        print('${docSnapshot.id} => ${docSnapshot.data()}');
        groups.add(
          Group.fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id),
        );
      }
    } catch (e) {
      print('Error fetching groups: $e');
    }
    return groups;
  }

  void _navigateToCreateGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const createGroupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Group Report",
          style: TextStyle(color: kButtonTextColor),
        ),
      ),
      body: Container(
        color: kScaffoldColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<Group>>(
                  future: futureGroups,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No groups found"));
                    } else {
                      final groups = snapshot.data!;
                      return ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Card(
                            color: kCardColor,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                group.grp_name,
                                style: kTitleStyle,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Members: ${group.memberIds.length}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Status: ',
                                      style: const TextStyle(color: Colors.grey), // Base style for "Status:"
                                      children: [
                                        TextSpan(
                                          text: group.statusOfApproved == 'true' || group.statusOfApproved.toLowerCase() == 'approved'
                                              ? 'Approved'
                                              : 'Pending',
                                          style: TextStyle(
                                            color: group.statusOfApproved == 'true' || group.statusOfApproved.toLowerCase() == 'approved'
                                                ? Colors.green
                                                : Colors.orange, // Color for "Approved" or "Pending"
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowMemberDetailScreen(
                                      grp_id: group.grp_id,
                                      numberOfMembers: group.memberIds.length,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToCreateGroupScreen,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: kWeatherTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
