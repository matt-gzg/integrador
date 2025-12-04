import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrador/model/clan_model.dart';
import 'package:integrador/model/clanMember_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -----------------------------------------------------------
  // STREAMS
  // -----------------------------------------------------------

  Stream<Clan> getClan(String clanId) {
    return _firestore
        .collection("clans")
        .doc(clanId)
        .snapshots()
        .map((d) => Clan.fromFirestore(d.id, d.data()!));
  }

  Stream<List<ClanMember>> getClanMembers(String clanId) {
    return _firestore
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

  Stream<List<Activity>> getClanActivities(String clanId) {
    return _firestore
        .collection("clans")
        .doc(clanId)
        .collection("exerciseLogs")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Activity.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  Stream<List<Clan>> getAllClans() {
    return _firestore
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
      // atualizar pontos do membro
      final m = await t.get(memberRef);
      int mp = m.data()?["points"] ?? 0;
      t.update(memberRef, { "points": mp + points });

      // atualizar pontos do clã
      final c = await t.get(clanRef);
      int cp = c.data()?["points"] ?? 0;
      t.update(clanRef, { "points": cp + points });
    });
  }


  // -----------------------------------------------------------
  // CRIAÇÃO E ENTRADA EM CLÃ
  // -----------------------------------------------------------

  /// Método para criar um novo clã + salvar líder como membro.
  Future<String> createClan({
    required Clan clan,
    required String leaderId,
    required String leaderName,
  }) async {
    final clanRef = _firestore.collection("clans").doc();

    final data = {
      "name": clan.name,
      "points": clan.points,
      "leaderId": leaderId,
    };

    await clanRef.set(data);

    // adiciona o líder como membro inicial
    await clanRef.collection("members").doc(leaderId).set({
      "name": leaderName,
      "points": 0,
    });

    return clanRef.id;
  }

  /// Adiciona membro normal ao clã
  Future<void> joinClan(String clanId, String userId, String userName) async {
    final memberRef = _firestore
        .collection("clans")
        .doc(clanId)
        .collection("members")
        .doc(userId);

    final snap = await memberRef.get();
    if (snap.exists) return;

    await memberRef.set({"name": userName, "points": 0});

    print("Usuário $userName entrou no clã $clanId");
  }

  // -----------------------------------------------------------
  // REGISTRO DE ATIVIDADE
  // -----------------------------------------------------------

  Future<void> registerClanActivity({
    required String clanId,
    required String userId,
    required String userName,
    required String activityName,
    required int points,
  }) async {
    final clanRef = _firestore.collection("clans").doc(clanId);
    final memberRef = clanRef.collection("members").doc(userId);
    final activitiesRef = clanRef.collection("activities");

    await _firestore.runTransaction((transaction) async {
      // 1. Registrar atividade
      transaction.set(activitiesRef.doc(), {
        "userId": userId,
        "userName": userName,
        "activity": activityName,
        "points": points,
        "timestamp": Timestamp.now(),
      });

      // 2. Atualizar pontos do membro
      final memberSnap = await transaction.get(memberRef);
      final currentMemberPoints = memberSnap.data()?["points"] ?? 0;

      transaction.update(memberRef, {"points": currentMemberPoints + points});

      // 3. Atualizar pontos do clã
      final clanSnap = await transaction.get(clanRef);
      final currentClanPoints = clanSnap.data()?["points"] ?? 0;

      transaction.update(clanRef, {"points": currentClanPoints + points});
    });
  }

  Future<void> updateMemberName(
    String clanId,
    String userId,
    String newName,
  ) async {
    await FirebaseFirestore.instance
        .collection("clans")
        .doc(clanId)
        .collection("members")
        .doc(userId)
        .update({"name": newName});
  }

  Future<void> leaveClan({
    required String clanId,
    required String userId,
  }) async {
    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Remover o membro da subcoleção do clã
      transaction.delete(clanRef.collection("members").doc(userId));

      // Remover o clanId do usuário
      transaction.update(userRef, {"clanId": ""});
    });
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
      // ---------------------------
      // 1. LEITURAS (obrigatório!)
      // ---------------------------

      // get #1 - dados do clan
      final clanSnap = await transaction.get(clanRef);
      if (!clanSnap.exists) throw Exception('Clã não encontrado.');

      if (clanSnap.data()?['leaderId'] != leaderId)
        throw Exception('Apenas o líder pode remover membros.');

      // get #2 - dados do membro
      final memberSnap = await transaction.get(memberRef);
      final memberPoints = memberSnap.data()?['points'] ?? 0;

      // get #3 - dados do usuário (necessário!!!)
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) throw Exception('Usuário não encontrado.');

      // ---------------------------
      // 2. WRITES (depois de tudo!)
      // ---------------------------

      // Remover membro da coleção
      transaction.delete(memberRef);

      // Atualizar pontos do clã
      final currentClanPoints = clanSnap.data()?['points'] ?? 0;
      final newClanPoints = (currentClanPoints - memberPoints)
          .clamp(0, double.infinity)
          .toInt();

      transaction.update(clanRef, {'points': newClanPoints});

      // Remover clanId do usuário
      transaction.update(userRef, {'clanId': ''});
    });
  }

  Stream<List<Clan>> getClansRanked() {
    return _firestore
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

    // Apagar members
    final membersSnap = await clanRef.collection("members").get();
    for (var doc in membersSnap.docs) {
      await doc.reference.delete();
    }

    // Apagar activities
    final activitiesSnap = await clanRef.collection("activities").get();
    for (var doc in activitiesSnap.docs) {
      await doc.reference.delete();
    }

    // Apagar documento do clã
    await clanRef.delete();
  }

}
