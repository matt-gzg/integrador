import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';

class HomePage extends StatefulWidget {
  final AppUser user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(child: Text("PAU NO CU"),);
  }
}