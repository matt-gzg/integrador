import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrador/model/exerciseLog_model.dart';

class ExerciseLogService {
  final String clanId;

  ExerciseLogService(this.clanId);

  CollectionReference get logsRef => FirebaseFirestore.instance
      .collection("clans")
      .doc(clanId)
      .collection("exerciseLogs");

  /// Calcula pontos baseado na intensidade e tempo
  int calculatePoints(String intensity, int minutes) {
    double multiplier;

    switch (intensity.toLowerCase()) {
      case 'baixa':
        multiplier = 0.5;
        break;
      case 'media':
        multiplier = 1.0;
        break;
      case 'alta':
        multiplier = 1.5;
        break;
      default:
        multiplier = 1.0;
    }

    return (minutes * multiplier).round();
  }

  // Registrar atividade
  Future<void> addExerciseLog({
    required String userId,
    required String userName,
    required String activityName,
    required String intensity,
    required int duration,
  }) async {
    final points = calculatePoints(intensity, duration);

    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // REFERÊNCIAS
      final logRef = logsRef.doc();
      final memberRef = clanRef.collection("members").doc(userId);
      final clanDocRef = clanRef;

      // ------------------------------------------------
      // 1. FAZER TODOS OS READS ANTES DE QUALQUER WRITE
      // ------------------------------------------------

      final memberSnap = await transaction.get(memberRef);
      final clanSnap = await transaction.get(clanDocRef);

      final currentMemberPoints = (memberSnap.data()?['points'] ?? 0) as int;
      final currentClanPoints = (clanSnap.data()?['points'] ?? 0) as int;

      // ------------------------------------------------
      // 2. SÓ AQUI COMEÇAM OS WRITES
      // ------------------------------------------------

      // Registrar log
      transaction.set(logRef, {
        'userId': userId,
        'userName': userName,
        'activityName': activityName,
        'intensity': intensity,
        'duration': duration,
        'points': points,
        'timestamp': Timestamp.now(),
      });

      // Atualizar pontos do membro
      transaction.update(memberRef, {'points': currentMemberPoints + points});

      // Atualizar pontos do clan
      transaction.update(clanDocRef, {'points': currentClanPoints + points});
    });
  }

  // Buscar logs do usuário
  Stream<List<ExerciseLog>> getUserLogs(String userId) {
    return logsRef
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => ExerciseLog.fromFirestore(
                  d.data() as Map<String, dynamic>,
                  d.id,
                ),
              )
              .toList(),
        );
  }

  // Adicione estes métodos no seu ExerciseLogService
  Future<void> updateExerciseLog({
    required String logId,
    required String activityName,
    required String intensity,
    required int duration,
  }) async {
    // Implementação para atualizar no Firebase
  }

  Future<void> deleteExerciseLog(String logId) async {
    // Implementação para excluir do Firebase
  }
}
