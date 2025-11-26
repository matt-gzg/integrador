import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:integrador/components/buttonAuth_component.dart';
import 'package:integrador/components/showAlert_component.dart';
import 'package:integrador/components/textFieldAuth_component.dart';
import 'package:integrador/services/auth_service.dart';
import 'package:integrador/view/joinApp_page.dart';
import 'package:integrador/view/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.amber[700]!, Colors.amber[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 25,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.lock, size: 60, color: Colors.black),
              ),
              SizedBox(height: 35),
              Text(
                'Welcome!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontFamily: 'CinzelDecorative',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Log in to continue to your deck',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
              SizedBox(height: 40),
              TextFieldAuthComponent(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              SizedBox(height: 18),
              TextFieldAuthComponent(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(color: Colors.amber[700], fontSize: 13),
                ),
              ),
              SizedBox(height: 25),
              ButtonAuthComponent(onTap: signUserIn, text: "Sign in"),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No account?', style: TextStyle(color: Colors.white70)),
                  SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Register here',
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUserIn() async {
    final auth = AuthService();
    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await auth.signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      print("USER LOGADO = ${FirebaseAuth.instance.currentUser}");
      Navigator.of(context, rootNavigator: true).pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JoinAppPage()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      switch (e.code){
        case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        showDialog(
          context: context,
          builder: (context) => ShowAlert(
            title: "Login error",
            message: "Incorrect Email or Password",
            icon: Icons.error_outline,
          ),
        );
        break;
      default:
        showDialog(
          context: context,
          builder: (context) => ShowAlert(
            title: "Error",
            message: e.message ?? "An unexpected error occurred",
            icon: Icons.error_outline,
          ),
        );
      }
    }
  }
}
