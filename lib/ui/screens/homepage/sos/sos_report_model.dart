import 'package:cloud_firestore/cloud_firestore.dart';

class SOSReport {
  final String? id;                    // Firestore document ID
  final String senderID;
  final String senderName;
  final String disasterType;
  final String disasterIcon;
  final String location;
  final String time;
  final String? details;
  final String imagePath;
  final String status;                 // pending | waiting | ongoing | done
  final List<String> rescuers;
  final Timestamp createdAt;

  SOSReport({
    this.id,
    required this.senderID,
    required this.senderName,
    required this.disasterType,
    required this.disasterIcon,
    required this.location,
    required this.time,
    this.details,
    required this.imagePath,
    this.status = "pending",
    this.rescuers = const [],
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderName': senderName,
      'disasterType': disasterType,
      'disasterIcon': disasterIcon,
      'location': location,
      'time': time,
      'details': details,
      'imagePath': imagePath,
      'status': status,
      'rescuers': rescuers,
      'createdAt': createdAt,
    };
  }

  factory SOSReport.fromMap(Map<String, dynamic> map, {String? id}) {
    return SOSReport(
      id: id,
      senderID: map['senderID'] ?? '',
      senderName: map['senderName'] ?? '',
      disasterType: map['disasterType'] ?? '',
      disasterIcon: map['disasterIcon'] ?? '',
      location: map['location'] ?? '',
      time: map['time'] ?? '',
      details: map['details'],
      imagePath: map['imagePath'] ?? '',
      status: map['status'] ?? 'pending',
      rescuers: List<String>.from(map['rescuers'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  factory SOSReport.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SOSReport.fromMap(data, id: doc.id);
  }
}
