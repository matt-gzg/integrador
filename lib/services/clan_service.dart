import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrador/model/activity_model.dart';
import 'package:integrador/model/clanMember_model.dart';
import 'package:integrador/model/clan_model.dart';

class ClanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Clan?> getClan(String clanId) {
    return _db.collection("clans").doc(clanId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Clan.fromFirestore(doc.data()!, doc.id);
    });
  }

  Stream<List<Clan>> getAllClans() {
    return _db.collection("clans").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Clan.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ClanMember>> getClanMembers(String clanId) {
    return _db
        .collection("clans")
        .doc(clanId)
        .collection("members")
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ClanMember.fromFirestore(d.data(), d.id)).toList());
  }

  Stream<List<Activity>> getClanActivities(String clanId) {
    return _db
        .collection("clans")
        .doc(clanId)
        .collection("activities")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Activity.fromFirestore(d.data(), d.id)).toList());
  }

  Future<String> createClan(Clan clan) async {
    final docRef = await _db.collection('clans').add(clan.toFirestore());
    return docRef.id;
  }

  Future<void> joinClan(String clanId, String userId, String userName) async {
    final db = FirebaseFirestore.instance;

    await db
        .collection("clans")
        .doc(clanId)
        .collection("members")
        .doc(userId)
        .set({
      "name": userName,
      "points": 0,
    });
  }

}
