import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrador/model/exercise_model.dart';

class ExerciseService {
  final String clanId;

  ExerciseService(this.clanId);

  CollectionReference get logsRef => FirebaseFirestore.instance
      .collection("clans")
      .doc(clanId)
      .collection("exerciseLogs");

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
      final logRef = logsRef.doc();
      final memberRef = clanRef.collection("members").doc(userId);
      final clanDocRef = clanRef;
      final memberSnap = await transaction.get(memberRef);
      final clanSnap = await transaction.get(clanDocRef);
      final currentMemberPoints = (memberSnap.data()?['points'] ?? 0) as int;
      final currentClanPoints = (clanSnap.data()?['points'] ?? 0) as int;

      transaction.set(logRef, {
        'userId': userId,
        'userName': userName,
        'activityName': activityName,
        'intensity': intensity,
        'duration': duration,
        'points': points,
        'timestamp': Timestamp.now(),
      });

      transaction.update(memberRef, {'points': currentMemberPoints + points});
      transaction.update(clanDocRef, {'points': currentClanPoints + points});
    });
  }

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

  Future<void> updateExerciseLog({
    required String logId,
    required String activityName,
    required String intensity,
    required int duration,
  }) async {
    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final logRef = logsRef.doc(logId);
      final logSnap = await transaction.get(logRef);

      if (!logSnap.exists) {
        throw Exception('Exercício não encontrado');
      }

      final oldLog = logSnap.data() as Map<String, dynamic>;
      final userId = oldLog['userId'] as String;
      final oldPoints = oldLog['points'] as int;
      final newPoints = calculatePoints(intensity, duration);
      final pointsDifference = newPoints - oldPoints;
      final memberRef = clanRef.collection("members").doc(userId);
      final clanDocRef = clanRef;
      final memberSnap = await transaction.get(memberRef);
      final clanSnap = await transaction.get(clanDocRef);
      final currentMemberPoints = (memberSnap.data()?['points'] ?? 0) as int;
      final currentClanPoints = (clanSnap.data()?['points'] ?? 0) as int;

      transaction.update(logRef, {
        'activityName': activityName,
        'intensity': intensity,
        'duration': duration,
        'points': newPoints,
      });

      transaction.update(memberRef, {
        'points': currentMemberPoints + pointsDifference,
      });

      transaction.update(clanDocRef, {
        'points': currentClanPoints + pointsDifference,
      });
    });
  }

  Future<void> deleteExerciseLog(String logId) async {
    final clanRef = FirebaseFirestore.instance.collection("clans").doc(clanId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final logRef = logsRef.doc(logId);
      final logSnap = await transaction.get(logRef);

      if (!logSnap.exists) {
        throw Exception('Exercício não encontrado');
      }

      final log = logSnap.data() as Map<String, dynamic>;
      final userId = log['userId'] as String;
      final pointsToRemove = log['points'] as int;
      final memberRef = clanRef.collection("members").doc(userId);
      final clanDocRef = clanRef;
      final memberSnap = await transaction.get(memberRef);
      final clanSnap = await transaction.get(clanDocRef);
      final currentMemberPoints = (memberSnap.data()?['points'] ?? 0) as int;
      final currentClanPoints = (clanSnap.data()?['points'] ?? 0) as int;
      transaction.delete(logRef);

      transaction.update(memberRef, {
        'points': (currentMemberPoints - pointsToRemove)
            .clamp(0, double.infinity)
            .toInt(),
      });

      transaction.update(clanDocRef, {
        'points': (currentClanPoints - pointsToRemove)
            .clamp(0, double.infinity)
            .toInt(),
      });
    });
  }
}
