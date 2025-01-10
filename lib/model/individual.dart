import 'package:cloud_firestore/cloud_firestore.dart';

class Individual {
  final String indivId;
  final String name;
  final String ic_number;
  final String phone_number;
  final String address;
  final String gender;
  final String race;
  final String nationality;
  final String birthday;
  final String passportNum;
  final String medical_history;
  final String user_id;
  final Timestamp timestamp;
  final String statusOfApproved;

  Individual({
    required this.indivId,
    required this.name,
    required this.ic_number,
    required this.phone_number,
    required this.address,
    required this.gender,
    required this.race,
    required this.nationality,
    required this.birthday,
    required this.passportNum,
    required this.medical_history,
    required this.user_id,
    required this.timestamp,
    required this.statusOfApproved,
  });

  factory Individual.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Individual(
      indivId: snapshot.id,
      name: snapshot.data()!['name'],
      ic_number: snapshot.data()!['ic_number'],
      phone_number: snapshot.data()!['phone_number'],
      address: snapshot.data()!['address'],
      gender: snapshot.data()!['gender'],
      race: snapshot.data()!['race'],
      nationality: snapshot.data()!['nationality'],
      birthday: snapshot.data()!['birthday'],
      passportNum: snapshot.data()!['passportNum'],
      medical_history: snapshot.data()!['medical_history'],
      user_id: snapshot.data()!['user_id'],
      timestamp: snapshot.data()!['timestamp'] as Timestamp,
      statusOfApproved: snapshot.data()!['statusOfApproved'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ic_number': ic_number,
      'phone_number': phone_number,
      'address': address,
      'gender': gender,
      'race': race,
      'nationality': nationality,
      'birthday': birthday,
      'passportNum': passportNum,
      'medical_history': medical_history,
      'user_id': user_id,
      'timestamp': timestamp,
      'statusOfApproved': statusOfApproved,
    };
  }

  factory Individual.fromMap(Map<String, dynamic> data, String indivId) {
    return Individual(
      indivId: indivId,
      name: data['name'] ?? '',
      ic_number: data['ic_number'] ?? '',
      phone_number: data['phone_number'] ?? '',
      address: data['address'] ?? '',
      gender: data['gender'] ?? '',
      race: data['race'] ?? '',
      nationality: data['nationality'] ?? '',
      birthday: data['birthday'] ?? '',
      passportNum: data['passportNum'] ?? '',
      medical_history: data['medical_history'] ?? '',
      user_id: data['user_id'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      statusOfApproved: data['statusOfApproved'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'indivId': indivId,
      'name': name,
      'ic_number': ic_number,
      'phone_number': phone_number,
      'address': address,
      'gender': gender,
      'race': race,
      'nationality': nationality,
      'birthday': birthday,
      'passportNum': passportNum,
      'medical_history': medical_history,
      'user_id': user_id,
      'timestamp': timestamp,
      'statusOfApproved': statusOfApproved,
    };
  }
}