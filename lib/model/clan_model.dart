class Clan {
  final String id;
  final String name;
  final int points;

  Clan({
    required this.id,
    required this.name,
    required this.points,
  });

  factory Clan.fromFirestore(Map<String, dynamic> json, String id) {
    return Clan(
      id: id,
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'points': points,
    };
  }
}
