import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_management_system/screens/EditMemberDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flood_management_system/component/constant.dart';
import 'package:flood_management_system/model/member.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:qr_image_generator/qr_image_generator.dart';

class ShowMemberDetailScreen extends StatefulWidget {
  final String grp_id;
  final int numberOfMembers;

  const ShowMemberDetailScreen({
    super.key,
    required this.grp_id,
    required this.numberOfMembers,
  });

  @override
  _ShowMemberDetailScreenState createState() => _ShowMemberDetailScreenState();
}

class _ShowMemberDetailScreenState extends State<ShowMemberDetailScreen> {
  bool _isLoading = true;
  List<Member> _members = [];
  Member? _leader;
  String? qrImageUrl;
  bool _isQRCodeSaved = false;
  @override
  void initState() {
    super.initState();
    _fetchMemberDetails();
    _checkQRCodeExistence();  }
  // Check if the QR code already exists in Firebase Storage
  Future<void> _checkQRCodeExistence() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child("qr_codes/${widget.grp_id}_qr.png");

      // Try to fetch the file
      final result = await storageRef.getDownloadURL();
      setState(() {
        qrImageUrl = result; // If found, set the URL
        _isQRCodeSaved = true; // Mark that the QR code is already saved
      });
    } catch (e) {
      print("QR code doesn't exist for this group: $e");
      setState(() {
        _isQRCodeSaved = false; // QR code not found
      });
    }
  }
   Future<void> _fetchMemberDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> groupDoc = await FirebaseFirestore
          .instance
          .collection('groups')
          .doc(widget.grp_id)
          .get();

      if (groupDoc.exists) {
        List<dynamic> memberIds = groupDoc.data()?['member_ids'] ?? [];
        String leaderId = groupDoc.data()?['leader_id'] ?? '';

        List<Future<Member>> memberFutures = memberIds
            .where((id) => id != leaderId)
            .map((id) => FirebaseFirestore.instance
            .collection('member_details')
            .doc(id)
            .get()
            .then((doc) => Member.fromFirestore(doc)))
            .toList();

        _members = await Future.wait(memberFutures);

        if (leaderId.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> leaderDoc =
          await FirebaseFirestore.instance
              .collection('member_details')
              .doc(leaderId)
              .get();
          if (leaderDoc.exists) {
            _leader = Member.fromFirestore(leaderDoc);
          }
        }
      }
    } catch (e) {
      print("Error fetching member details: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String qrData = 'Group ID: ${widget.grp_id}\nMembers: ${widget.numberOfMembers}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text("Group Details"),
        centerTitle: true,
      ),
      backgroundColor: kScaffoldColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leader Details', style: kTitleStyle),
            const SizedBox(height: 16.0),
            if (_leader != null)
              _buildLeaderCard()
            else
              const Text('Leader not found', style: TextStyle(color: Colors.red)),

            const SizedBox(height: 16.0),
            Text('Members', style: kTitleStyle),
            const SizedBox(height: 16.0),
            _members.isEmpty
                ? const Text('No members found', style: TextStyle(color: Colors.red))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                return _buildMemberCard(_members[index]);
              },
            ),
            const SizedBox(height: 16.0),
            if (_isQRCodeSaved)
              Column(
                children: [
                  Image.network(qrImageUrl!),
                  const SizedBox(height: 16.0),
                  Text("QR Code is already saved."),
                ],
              )
            else
              Center(
                child: ElevatedButton(
                  onPressed: () => QRCodeUploader(context, widget.grp_id).saveQRImage(qrData, (url) {
                    setState(() {
                      qrImageUrl = url;
                      _isQRCodeSaved = true;
                    });
                  }),style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kWeatherTextColor, // Set the color of the text
                ),
                  child: const Text('Get QR Code'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderCard() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditMemberDetailsScreen(member: _leader!),
        ),
      ),
      child: Card(
        color: kCardColor,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildDetailsList(_leader!),
        ),
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditMemberDetailsScreen(member: member),
        ),
      ),
      child: Card(
        color: kCardColor,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildDetailsList(member),
        ),
      ),
    );
  }

  Widget _buildDetailsList(Member member) {
    List<Map<String, String>> details = [
      {'Name': member.name},
      {'Position': member.position},
      {'Gender': member.gender},
      {'IC Number': member.icNumber},
      {'Phone Number': member.phoneNumber},
      {'Nationality': member.nationality},
      {'Address': member.address},
      {'Race': member.race ?? 'Not available'},
      {'Medical History': member.medical_history ?? 'Not available'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((detail) {
        final key = detail.keys.first;
        final value = detail[key]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 7, child: Text(value)),
            ],
          ),
        );
      }).toList(),
    );
  }
}


class QRCodeUploader {
  final BuildContext context;
  final String grpId; // Add grpId as a parameter

  QRCodeUploader(this.context, this.grpId); // Modify the constructor to accept grpId

  Future<void> saveQRImage(String data, Function(String) onUploadSuccess) async {
    try {
      // Generate the QR code image in a temporary directory.
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/group_qr.png';

      final generator = QRGenerator();
      await generator.generate(
        data: data,
        filePath: filePath,
        scale: 10,
        padding: 2,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        errorCorrectionLevel: ErrorCorrectionLevel.medium,
      );

      // Use grpId passed from the widget class
      final imageRef = FirebaseStorage.instance.ref().child('qr_codes/${grpId}_qr.png');

      // Upload the image to Firebase Storage
      final file = File(filePath);
      await imageRef.putFile(file);

      // Get the download URL for the uploaded QR code image.
      final downloadUrl = await imageRef.getDownloadURL();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code uploaded successfully: $downloadUrl')),
      );

      print("QR Code Download URL: $downloadUrl");

      // Call the callback with the URL
      onUploadSuccess(downloadUrl);

    } on FirebaseException catch (e) {
      print("Firebase upload failed: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload QR Code')),
      );
    } catch (e) {
      print("Error during QR Code upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while saving the QR Code')),
      );
    }
  }
}


