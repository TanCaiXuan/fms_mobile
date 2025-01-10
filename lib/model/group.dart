import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String grp_id;
  final String grp_name;
  final String leaderId;
  final String location;
  final List<String> memberIds;
  final String user_id;
  final DateTime timestamp;
  final String statusOfApproved; // Added statusOfApproved field

  Group({
    required this.grp_id,
    required this.grp_name,
    required this.leaderId,
    required this.location,
    required this.memberIds,
    required this.user_id,
    required this.timestamp,
    required this.statusOfApproved,
  });

  // Factory method to create a Group object from Firestore data
  factory Group.fromMap(Map<String, dynamic> data, String documentId) {
    return Group(
      grp_id: data['grp_id'] ?? '',
      grp_name: data['grp_name'] ?? '',
      leaderId: data['leader_id'] ?? '',
      location: data['location'] ?? '',
      memberIds: List<String>.from(data['member_ids'] ?? []),
      user_id: data['user_id'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      statusOfApproved: data['statusOfApproved'] ?? false, // Default to false if not provided
    );
  }

  // Method to convert a Group object into a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'grp_id': grp_id,
      'grp_name': grp_name,
      'leader_id': leaderId,
      'location': location,
      'member_ids': memberIds,
      'user_id': user_id,
      'timestamp': Timestamp.fromDate(timestamp),
      'statusOfApproved': statusOfApproved,
    };
  }
}