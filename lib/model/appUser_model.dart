import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String? id;
  String? clanId;
  String name;
  String email;
  int points;
  int level;
  DateTime createdAt;
  String? photoUrl;
  bool isAdmin;

  AppUser({
    this.id,
    this.clanId,
    required this.name,
    required this.email,
    this.points = 0,
    this.level = 1,
    required this.createdAt,
    this.photoUrl,
    this.isAdmin = false,
  });

  AppUser copyWith({
    String? id,
    String? clanId,
    String? name,
    String? email,
    int? points,
    int? level,
    DateTime? createdAt,
    String? photoUrl,
    bool? isAdmin,
  }) {
    return AppUser(
      id: id ?? this.id,
      clanId: clanId ?? this.clanId,
      name: name ?? this.name,
      email: email ?? this.email,
      points: points ?? this.points,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  factory AppUser.fromFirestore(Map<String, dynamic> json, String documentId) {
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
      photoUrl: json['photoUrl'],
      isAdmin: json['isAdmin'] ?? false,
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
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
    };
  }
}
