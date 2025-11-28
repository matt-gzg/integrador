import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String? id;
  String? clanId;
  final String name;
  final String email;
  final int points;
  final int level;
  final DateTime createdAt;

  AppUser({
    this.id,
    this.clanId,
    required this.name,
    required this.email,
    this.points = 0,
    this.level = 1,
    required this.createdAt,
  });

  AppUser copyWith({
    String? id,
    String? clanId,
    String? name,
    String? email,
    int? points,
    int? level,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      clanId: clanId ?? this.clanId,
      name: name ?? this.name,
      email: email ?? this.email,
      points: points ?? this.points,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  factory AppUser.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return AppUser(
      id: documentId,
      clanId: json['clanId'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      points: json['points'] is int ? json['points'] : 0,
      level: json['level'] is int ? json['level'] : 1,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'clanId': clanId,
      'email': email,
      'points': points,
      'level': level,
      'createdAt': createdAt,
    };
  }
}
