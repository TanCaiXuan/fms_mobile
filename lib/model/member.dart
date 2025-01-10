import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String member_id;
  final String user_id;
  final String name;
  final String icNumber;
  final String phoneNumber;
  final String address;
  final String gender;
  final String race;
  final String position;
  final String grpId;
  final Timestamp timestamp;
  final String medical_history;
  final String nationality;
  final String birthday;
  final String passportNum;


  Member({
    required this.user_id,
    required this.name,
    required this.icNumber,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.race,
    required this.position,
    required this.grpId,
    required this.timestamp,
    required this.medical_history,
    required this.nationality,
    required this.member_id,
    required this.birthday,
    required this.passportNum,
  });

  factory Member.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Member(
      user_id: snapshot.id,
      name: snapshot.data()!['name'],
      icNumber: snapshot.data()!['ic_number'],
      phoneNumber: snapshot.data()!['phone_number'],
      address: snapshot.data()!['address'],
      gender: snapshot.data()!['gender'],
      race: snapshot.data()!['race'],
      position: snapshot.data()!['position'],
      grpId: snapshot.data()!['grp_id'],
      timestamp: snapshot.data()!['timestamp'],
      medical_history: snapshot.data()!['medical_history'],
      nationality: snapshot.data()!['nationality'],
      member_id: snapshot.data()!['member_id'],
      birthday: snapshot.data()!['birthday'],
      passportNum: snapshot.data()!['passportNum'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ic_number': icNumber,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
      'race': race,
      'position': position,
      'grp_id': grpId,
      'timestamp': timestamp,
      'medical_history':medical_history,
      'nationality':nationality,
      'member_id':member_id,
      'passportNum':passportNum,
    };
  }
}