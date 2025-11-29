class Clan {
  String id;
  String name;
  int points;
  String? leaderId;

  Clan({
    required this.id,
    required this.name,
    required this.points,
    this.leaderId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "points": points,
      "leaderId": leaderId,
    };
  }

  factory Clan.fromFirestore(String id, Map<String, dynamic> map) {
    return Clan(
      id: id,
      name: map['name'],
      points: map['points'] ?? 0,
      leaderId: map['leaderId'],
    );
  }
}
