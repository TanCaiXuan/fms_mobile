import 'package:cloud_firestore/cloud_firestore.dart';

class Pps {
  String? baby_boys;
  String? baby_girls;
  String? boys;
  String? capacity;
  String? district;
  String? families;
  String? girls;
  String? men;
  String? name;
  String? open;
  String? subdistrict;
  String? victims;
  String? women;

  Pps({
    this.baby_boys,
    this.baby_girls,
    this.boys,
    this.capacity,
    this.district,
    this.families,
    this.girls,
    this.men,
    this.name,
    this.open,
    this.subdistrict,
    this.victims,
    this.women,
  });

  factory Pps.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return Pps(
      baby_boys: data['baby_boys'],
      baby_girls: data['baby_girls'],
      boys: data['boys'],
      capacity: data['capacity'],
      district: data['district'],
      families: data['families'],
      girls: data['girls'],
      men: data['men'],
      name: data['name'],
      open: data['open'],
      subdistrict: data['subdistrict'],
      victims: data['victims'],
      women: data['women'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'baby_boys': baby_boys,
      'baby_girls': baby_girls,
      'boys': boys,
      'capacity': capacity,
      'district': district,
      'families': families,
      'girls': girls,
      'men': men,
      'name': name,
      'open': open,
      'subdistrict': subdistrict,
      'victims': victims,
      'women': women,
    };
  }
}