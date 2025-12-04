import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrador/model/clan_model.dart';
import 'package:integrador/model/clanMember_model.dart';
import 'package:integrador/model/exercise_model.dart';

class ClanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Clan> getClan(String clanId) {
    return _db
        .collection("clans")
        .doc(clanId)
        .snapshots()
        .map((d) => Clan.fromFirestore(d.id, d.data()!));
  }

  Stream<List<ClanMember>> getClanMembers(String clanId) {
    return _db
        .collection("clans")
        .doc(clanId)
        .collection("members")
        .orderBy("points", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ClanMember.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  Stream<List<Exercise>> getClanExercises(String clanId) {
    return _db
        .collection("clans")
        .doc(clanId)
        .collection("exerciseLogs")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Exercise.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  Stream<List<Exercise>> getRecentClanExercises(String clanId) {
    return _db
        .collection("clans")
        .doc(clanId)
        .collection("exerciseLogs")
        .orderBy("timestamp", descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Exercise.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  Stream<List<Clan>> getAllClans() {
    return _db
        .collection("clans")
        .orderBy("points", descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Clan.fromFirestore(d.id, d.data())).toList(),
        );
  }

  Future<void> addExerciseToClan({
    required String clanId,
    required Exercise exercise,
  }) async {
    final ref = _db
        .collection("clans")
        .doc(clanId)
        .collection("exerciseLogs")
        .doc();

    await ref.set(exercise.toFirestore());
  }

  Future<void> applyExercisePoints({
    required String clanId,
    required String userId,
    required int points,
  }) async {
    final clanRef = _db.collection("clans").doc(clanId);
    final memberRef = clanRef.collection("members").doc(userId);

    await _db.runTransaction((t) async {
      final m = await t.get(memberRef);
      int mp = m.data()?["points"] ?? 0;
      t.update(memberRef, {"points": mp + points});

      final c = await t.get(clanRef);
      int cp = c.data()?["points"] ?? 0;
      t.update(clanRef, {"points": cp + points});
    });
  }

  Future<String> createClan({
    required Clan clan,
    required String leaderId,
    required String leaderName,
  }) async {
    final clanRef = _db.collection("clans").doc();

    final data = {
      "name": clan.name,
      "points": clan.points,
      "leaderId": leaderId,
    };

    await clanRef.set(data);

    await clanRef.collection("members").doc(leaderId).set({
      "name": leaderName,
      "points": 0,
    });

    return clanRef.id;
  }

  Future<void> joinClan(String clanId, String userId, String userName) async {
    final memberRef = _db
        .collection("clans")
        .doc(clanId)
        .collection("members")
        .doc(userId);

    final snap = await memberRef.get();
    if (snap.exists) return;

    await memberRef.set({"name": userName, "points": 0});

    print("Usuário $userName entrou no clã $clanId");
  }

  Future<void> registerClanActivity({
    required String clanId,
    required String userId,
    required String userName,
    required String activityName,
    required int points,
  }) async {
    final clanRef = _db.collection("clans").doc(clanId);
    final memberRef = clanRef.collection("members").doc(userId);
    final activitiesRef = clanRef.collection("activities");

    await _db.runTransaction((transaction) async {
      transaction.set(activitiesRef.doc(), {
        "userId": userId,
        "userName": userName,
        "activity": activityName,
        "points": points,
        "timestamp": Timestamp.now(),
      });

      final memberSnap = await transaction.get(memberRef);
      final currentMemberPoints = memberSnap.data()?["points"] ?? 0;

      transaction.update(memberRef, {"points": currentMemberPoints + points});

      final clanSnap = await transaction.get(clanRef);
      final currentClanPoints = clanSnap.data()?["points"] ?? 0;

      transaction.update(clanRef, {"points": currentClanPoints + points});
    });
  }

  Future<void> updateMemberName({
    required String clanId,
    required String userId,
    required String newName,
  }) async {
    await _firestore
        .collection("clans")
        .doc(clanId)
        .collection("members")
        .doc(userId)
        .update({"name": newName});
  }

  Future<void> removeMember({
    required String clanId,
    required String memberId,
    required String leaderId,
  }) async {
    final clanRef = _firestore.collection('clans').doc(clanId);
    final memberRef = clanRef.collection('members').doc(memberId);
    final userRef = _firestore.collection('users').doc(memberId);

    await _firestore.runTransaction((transaction) async {
      final clanSnap = await transaction.get(clanRef);
      if (!clanSnap.exists) throw Exception('Clã não encontrado.');

      if (clanSnap.data()?['leaderId'] != leaderId)
        throw Exception('Apenas o líder pode remover membros.');

      final memberSnap = await transaction.get(memberRef);
      final memberPoints = memberSnap.data()?['points'] ?? 0;
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) throw Exception('Usuário não encontrado.');

      transaction.delete(memberRef);

      final currentClanPoints = clanSnap.data()?['points'] ?? 0;
      final newClanPoints = (currentClanPoints - memberPoints)
          .clamp(0, double.infinity)
          .toInt();

      transaction.update(clanRef, {'points': newClanPoints});

      transaction.update(userRef, {'clanId': ''});
    });
  }

  Future<void> leaveClan({
    required String clanId,
    required String userId,
  }) async {
    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(clanRef.collection("members").doc(userId));

      transaction.update(userRef, {"clanId": ""});
    });
  }

  Stream<List<Clan>> getClansRanked() {
    return _db
        .collection("clans")
        .orderBy("points", descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Clan.fromFirestore(d.id, d.data())).toList(),
        );
  }

  Future<void> deleteClan(String clanId) async {
    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);
    final batch = FirebaseFirestore.instance.batch();

    final membersSnap = await clanRef.collection("members").get();
    for (var doc in membersSnap.docs) {
      batch.delete(doc.reference);
    }

    final activitiesSnap = await clanRef.collection("activities").get();
    for (var doc in activitiesSnap.docs) {
      batch.delete(doc.reference);
    }

    final exerciseLogsSnap = await clanRef.collection("exerciseLogs").get();
    for (var doc in exerciseLogsSnap.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(clanRef);

    await batch.commit();
  }

  Future<void> leaderLeaveClan({
    required String clanId,
    required String userId,
    required String leaderId,
  }) async {
    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);
    final usersCollection = FirebaseFirestore.instance.collection("users");

    final clanSnap = await clanRef.get();
    if (clanSnap.data()?['leaderId'] == leaderId) {
      final membersSnap = await clanRef.collection("members").get();
      final batch = FirebaseFirestore.instance.batch();
      for (var memberDoc in membersSnap.docs) {
        final memberId = memberDoc.id;
        batch.update(usersCollection.doc(memberId), {'clanId': ''});
      }
      await batch.commit();
      await deleteClan(clanId);
    } else {
      await leaveClan(clanId: clanId, userId: userId);
    }
  }
}
