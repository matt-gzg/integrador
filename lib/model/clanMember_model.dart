class ClanMember {
  final String id;
  final String name;
  final int points;

  ClanMember({
    required this.id,
    required this.name,
    required this.points,
  });

  factory ClanMember.fromFirestore(Map<String, dynamic> json, String id) {
    return ClanMember(
      id: id,
      name: json['name'],
      points: json['points'],
    );
  }
}
