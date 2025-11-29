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
    // Mostrar loading elegante
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey[800]!,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Criando sua conta...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
              title: "Erro na Senha",
              message: "As senhas não coincidem.",
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
                title: "Erro no Email",
                message: "Já existe um usuário com este email!",
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
                title: "Erro no Email",
                message: "O formato do email é inválido.",
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
                title: "Erro na Senha",
                message: "A senha deve ter pelo menos 6 caracteres.",
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
                title: "Erro",
                message: e.message ?? "Ocorreu um erro inesperado",
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
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              
              // Logo/Ícone
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade600,
                      Colors.orange.shade800,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              
              // Título
              Text(
                'Criar Conta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Junte-se ao clã e comece sua jornada',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              
              // Campos de entrada
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextFieldAuthComponent(
                      controller: nameController,
                      hintText: "Nome",
                      obscureText: false,
                    ),
                    SizedBox(height: 20),
                    TextFieldAuthComponent(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                    ),
                    SizedBox(height: 20),
                    TextFieldAuthComponent(
                      controller: passwordController,
                      hintText: "Senha",
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextFieldAuthComponent(
                      controller: confirmPasswordController,
                      hintText: "Confirmar Senha",
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // Botão de registro
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade600,
                      Colors.orange.shade800,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: register,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'CRIAR CONTA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // Divisor
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey[800],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OU',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey[800],
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              
              // Link para login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem uma conta?',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Fazer Login',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              
              // Informações adicionais
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[800]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ao criar uma conta, você concorda com nossos termos de serviço.',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}