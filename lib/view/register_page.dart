import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:integrador/components/buttonAuth_component.dart';
import 'package:integrador/components/showAlert_component.dart';
import 'package:integrador/components/textFieldAuth_component.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/services/appUser_service.dart';
import 'package:integrador/view/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();

  void showAlert(String mensagem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text(mensagem, style: TextStyle(color: Colors.white)),
        );
      },
    );
  }

  void register() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.amber));
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        final uid = cred.user!.uid;
        final newUser = AppUser(
          id: uid,
          clanId: null,
          name: nameController.text,
          email: emailController.text.trim(),
          points: 0,
          level: 1,
          createdAt: DateTime.now(),
        );
        await AppUserService().createUser(newUser);

        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return ShowAlert(
              title: "Password error",
              message: "Passwords don't match.",
              icon: Icons.error_outline,
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      switch (e.code) {
        case 'email-already-in-use':
          showDialog(
            context: context,
            builder: (context) {
              return ShowAlert(
                title: "Email error",
                message: "There is already an user with this email!",
                icon: Icons.error_outline,
              );
            },
          );
          break;
        case 'invalid-email':
          showDialog(
            context: context,
            builder: (context) {
              return ShowAlert(
                title: "Email error",
                message: "The email format is invalid.",
                icon: Icons.error_outline,
              );
            },
          );
          break;
        case 'weak-password':
          showDialog(
            context: context,
            builder: (context) {
              return ShowAlert(
                title: "Password error",
                message: "The password must be at least 6 characters long.",
                icon: Icons.error_outline,
              );
            },
          );
          break;
        default:
          showDialog(
            context: context,
            builder: (context) {
              return ShowAlert(
                title: "Error",
                message: e.message ?? "A unexpected error happened",
                icon: Icons.error_outline,
              );
            },
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Container(
                height: 110,
                width: 110,
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
                child: Icon(Icons.person_add, size: 55, color: Colors.black),
              ),
              SizedBox(height: 30),
              Text(
                "Create your Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'CinzelDecorative',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Join the realm and start building your deck!",
                style: TextStyle(color: Colors.white54, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 35),
              TextFieldAuthComponent(
                controller: nameController,
                hintText: "Name",
                obscureText: false,
              ),
              SizedBox(height: 18),
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
              SizedBox(height: 18),
              TextFieldAuthComponent(
                controller: confirmPasswordController,
                hintText: "Confirm your password",
                obscureText: true,
              ),
              SizedBox(height: 25),
              ButtonAuthComponent(onTap: register, text: "Register"),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      "Log in",
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
}
