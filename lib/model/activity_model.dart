import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String id;
  String userId;
  String userName;
  String activity;
  int points;
  DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.activity,
    required this.points,
    required this.createdAt,
  });

  factory Activity.fromFirestore(Map<String, dynamic> json, String id) {
    return Activity(
      id: id,
      userId: json['userId'],
      userName: json['userName'],
      activity: json['activity'],
      points: (json['points'] as num).toInt(),
      createdAt: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
