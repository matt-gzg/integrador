import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';

class ProfilePage extends StatelessWidget {
  final AppUser user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          "Nome: ${user.name}\nEmail: ${user.email}",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
