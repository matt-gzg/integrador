import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrador/model/appUser_model.dart';

class AppUserService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUser(AppUser user) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final data = user.toFirestore();
    return users.doc(uid).set(data);
  }

  Stream<AppUser?> getUser() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    });
  }

  Future<void> updateUser(AppUser user) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final data = user.toFirestore();
    return users.doc(uid).update(data);
  }

  Future<void> deleteUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return users.doc(uid).delete();
  }

  Future<void> updateUserName(String newName, String? clanId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;

    // 1 — Atualiza nome no documento do usuário
    await db.collection("users").doc(uid).update({
      "name": newName,
    });

    // 2 — Atualiza nome no clã (se estiver em um)
    if (clanId != null && clanId.isNotEmpty) {
      await db
          .collection("clans")
          .doc(clanId)
          .collection("members")
          .doc(uid)
          .update({"name": newName});
    }
  }

  Future<void> removeUserFromClan(String uid) async {
    await users.doc(uid).update({
      "clanId": "",
    });
  }

}
