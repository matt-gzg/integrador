import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';

class ExerciseLogPage extends StatelessWidget {
  final AppUser user;

  const ExerciseLogPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log de Exercícios"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          "Exercícios do usuário: ${user.name}",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
