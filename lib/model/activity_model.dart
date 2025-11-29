import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
  final String userName;
  final String activity;
  final int points;
  final DateTime createdAt;

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
