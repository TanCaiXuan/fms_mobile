import 'package:cloud_firestore/cloud_firestore.dart';

class River {
  final String no;
  final String stationId;
  final String stationName;
  final String district;
  final String mainBasin;
  final String subRiverBasin;
  final String lastUpdated;
  final String wl; // Water Level
  final String wlLink; // Water Level Link
  final String normal;
  final String alert;
  final String warning;
  final String danger;
  final Timestamp timestamp;

  River({
    required this.no,
    required this.stationId,
    required this.stationName,
    required this.district,
    required this.mainBasin,
    required this.subRiverBasin,
    required this.lastUpdated,
    required this.wl,
    required this.wlLink,
    required this.normal,
    required this.alert,
    required this.warning,
    required this.danger,
    required this.timestamp,
  });

  factory River.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return River(
      no: snapshot.data()!['no'],
      stationId: snapshot.data()!['station_id'],
      stationName: snapshot.data()!['station_name'],
      district: snapshot.data()!['district'],
      mainBasin: snapshot.data()!['main_basin'],
      subRiverBasin: snapshot.data()!['sub_river_basin'],
      lastUpdated: snapshot.data()!['last_updated'],
      wl: snapshot.data()!['wl'],
      wlLink: snapshot.data()!['wl_link'],
      normal: snapshot.data()!['normal'],
      alert: snapshot.data()!['alert'],
      warning: snapshot.data()!['warning'],
      danger: snapshot.data()!['danger'],
      timestamp: snapshot.data()!['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'no': no,
      'station_id': stationId,
      'station_name': stationName,
      'district': district,
      'main_basin': mainBasin,
      'sub_river_basin': subRiverBasin,
      'last_updated': lastUpdated,
      'wl': wl,
      'wl_link': wlLink,
      'normal': normal,
      'alert': alert,
      'warning': warning,
      'danger': danger,
      'timestamp': timestamp,
    };
  }
}