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
}
