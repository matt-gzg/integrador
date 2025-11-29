import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseLog {
  final String id;
  final String userId;
  final String userName;
  final String activityName;
  final String intensity;
  final int duration; // minutos
  final int points;
  final DateTime timestamp;

  ExerciseLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.activityName,
    required this.intensity,
    required this.duration,
    required this.points,
    required this.timestamp,
  });

  factory ExerciseLog.fromFirestore(Map<String, dynamic> json, String id) {
    return ExerciseLog(
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
