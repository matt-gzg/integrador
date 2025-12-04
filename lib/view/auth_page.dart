import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:integrador/view/admin_page.dart';
import 'package:integrador/view/joinApp_page.dart';
import 'package:integrador/view/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoginPage();
          }

          final user = snapshot.data!;

          // Buscar dados do Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              // Carregando
              if (!userSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final data = userSnapshot.data!.data() as Map<String, dynamic>?;

              // Segurança extra caso o documento não exista
              if (data == null) {
                return JoinAppPage();
              }

              final isAdmin = data["isAdmin"] == true;

              // REDIRECIONAMENTO FINAL
              if (isAdmin) {
                return AdminPage();
              } else {
                return JoinAppPage();
              }
            },
          );
        },
      ),
    );
  }
}
