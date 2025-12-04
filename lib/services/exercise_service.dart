import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrador/model/exercise_model.dart';

class ExerciseService {
  final String clanId;

  ExerciseService(this.clanId);

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
  Stream<List<Exercise>> getUserLogs(String userId) {
    return logsRef
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => Exercise.fromFirestore(
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
    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // REFERÊNCIAS
      final logRef = logsRef.doc(logId);
      final logSnap = await transaction.get(logRef);

      if (!logSnap.exists) {
        throw Exception('Exercício não encontrado');
      }

      final oldLog = logSnap.data() as Map<String, dynamic>;
      final userId = oldLog['userId'] as String;
      final oldPoints = oldLog['points'] as int;
      final oldIntensity = oldLog['intensity'] as String;
      final oldDuration = oldLog['duration'] as int;

      // Calcula os novos pontos
      final newPoints = calculatePoints(intensity, duration);

      // Calcula a diferença de pontos
      final pointsDifference = newPoints - oldPoints;

      // REFERÊNCIAS
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

      // Atualizar o log
      transaction.update(logRef, {
        'activityName': activityName,
        'intensity': intensity,
        'duration': duration,
        'points': newPoints,
      });

      // Atualizar pontos do membro
      transaction.update(memberRef, {
        'points': currentMemberPoints + pointsDifference,
      });

      // Atualizar pontos do clan
      transaction.update(clanDocRef, {
        'points': currentClanPoints + pointsDifference,
      });
    });
  }

  Future<void> deleteExerciseLog(String logId) async {
    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // REFERÊNCIAS
      final logRef = logsRef.doc(logId);
      final logSnap = await transaction.get(logRef);

      if (!logSnap.exists) {
        throw Exception('Exercício não encontrado');
      }

      final log = logSnap.data() as Map<String, dynamic>;
      final userId = log['userId'] as String;
      final pointsToRemove = log['points'] as int;

      // REFERÊNCIAS
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

      // Deletar o log
      transaction.delete(logRef);

      // Remover pontos do membro
      transaction.update(memberRef, {
        'points': (currentMemberPoints - pointsToRemove)
            .clamp(0, double.infinity)
            .toInt(),
      });

      // Remover pontos do clan
      transaction.update(clanDocRef, {
        'points': (currentClanPoints - pointsToRemove)
            .clamp(0, double.infinity)
            .toInt(),
      });
    });
  }
}
