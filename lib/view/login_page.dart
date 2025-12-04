import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:integrador/components/showAlert_component.dart';
import 'package:integrador/components/textFieldAuth_component.dart';
import 'package:integrador/services/auth_service.dart';
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
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: <Widget>[
              SizedBox(height: 40),

              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.orange.shade800],
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
                  Icons.lock_outline_rounded,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),

              // Título
              Text(
                'Bem-vindo de Volta',
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
                'Entre para acessar seu clã',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 50),

              // Campos de entrada
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
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
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Esqueci senha
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: showEmailResetPopup,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Botão de login
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.orange.shade800],
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
                  onPressed: signUserIn,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'ENTRAR',
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
                    child: Divider(color: Colors.grey[800], thickness: 1),
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
                    child: Divider(color: Colors.grey[800], thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Registrar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem uma conta?',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Registre-se',
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
            ],
          ),
        ),
      ),
    );
  }

  void showEmailResetPopup() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Recuperar Senha",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Digite o email onde deseja receber o link:",
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "email@exemplo.com",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final email = controller.text.trim();

              Navigator.pop(context);

              if (email.isEmpty) {
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => ShowAlert(
                    title: "Email necessário",
                    message: "Digite um email válido.",
                    icon: Icons.error_outline,
                  ),
                );
                return;
              }

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );

                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => ShowAlert(
                    title: "Email enviado!",
                    message:
                        "Um link de recuperação foi enviado para:\n\n$email",
                    icon: Icons.check_circle_outline,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => ShowAlert(
                    title: "Erro",
                    message:
                        "Não foi possível enviar o email. Verifique se está correto.",
                    icon: Icons.error_outline,
                  ),
                );
              }
            },
            child: Text("Enviar", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => ShowAlert(
          title: "Email necessário",
          message: "Digite seu email no campo acima para recuperar a senha.",
          icon: Icons.error_outline,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showDialog(
        context: context,
        builder: (context) => ShowAlert(
          title: "Email enviado!",
          message: "Enviamos um link de recuperação para $email.",
          icon: Icons.check_circle_outline,
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => ShowAlert(
          title: "Erro",
          message:
              "Não foi possível enviar o email. Verifique se o email está correto.",
          icon: Icons.error_outline,
        ),
      );
    }
  }

  void signUserIn() async {
    final auth = AuthService();

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
            border: Border.all(color: Colors.grey[800]!),
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
                'Entrando...',
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
      await auth.signIn(
        email: emailController.text,
        password: passwordController.text,
      );

      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Limpar controllers
      emailController.clear();
      passwordController.clear();

      // O AuthPage detectará a mudança automaticamente e redirecionará
      // Não precisa fazer mais nada aqui!
    } on FirebaseAuthException catch (e) {

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          showDialog(
            context: context,
            builder: (context) => ShowAlert(
              title: "Erro no Login",
              message: "Email ou senha incorretos",
              icon: Icons.error_outline,
            ),
          );
          break;
        default:
          showDialog(
            context: context,
            builder: (context) => ShowAlert(
              title: "Erro",
              message: e.message ?? "Ocorreu um erro inesperado",
              icon: Icons.error_outline,
            ),
          );
      }
    }
  }
}
