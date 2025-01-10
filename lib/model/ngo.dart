import 'package:cloud_firestore/cloud_firestore.dart';

class Ngo {
  final String country;
  final String facebookUrl;
  final String location;
  final String ngoName;
  final List<String> subWorkAreas;
  final String websiteUrl;
  final List<String> workAreas;

  Ngo({
    required this.country,
    required this.facebookUrl,
    required this.location,
    required this.ngoName,
    required this.subWorkAreas,
    required this.websiteUrl,
    required this.workAreas,
  });

  factory Ngo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Ngo(
      country: snapshot.data()!['country'],
      facebookUrl: snapshot.data()!['facebook_url'],
      location: snapshot.data()!['location'],
      ngoName: snapshot.data()!['ngo_name'],
      subWorkAreas: List<String>.from(snapshot.data()!['sub_work_areas']),
      websiteUrl: snapshot.data()!['website_url'],
      workAreas: List<String>.from(snapshot.data()!['work_areas']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'country': country,
      'facebook_url': facebookUrl,
      'location': location,
      'ngo_name': ngoName,
      'sub_work_areas': subWorkAreas,
      'website_url': websiteUrl,
      'work_areas': workAreas,
    };
  }
}
