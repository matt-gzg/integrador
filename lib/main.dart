import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:integrador/firebase_options.dart';
import 'package:integrador/view/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR');
  runApp(MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false));
}
