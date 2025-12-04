import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  String id;
  String userId;
  String userName;
  String activityName;
  String intensity;
  int duration;
  int points;
  DateTime timestamp;

  Exercise({
    required this.id,
    required this.userId,
    required this.userName,
    required this.activityName,
    required this.intensity,
    required this.duration,
    required this.points,
    required this.timestamp,
  });

  factory Exercise.fromFirestore(Map<String, dynamic> json, String id) {
    return Exercise(
      id: id,
      userId: json['userId'],
      userName: json['userName'],
      activityName: json['activityName'],
      intensity: json['intensity'],
      duration: json['duration'],
      points: json['points'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'activityName': activityName,
      'intensity': intensity,
      'duration': duration,
      'points': points,
      'timestamp': timestamp,
    };
  }
}
