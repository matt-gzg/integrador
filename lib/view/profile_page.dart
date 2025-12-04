import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrador/model/appUser_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrador/view/auth_page.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;
  final Function(AppUser) onUserUpdated;

  const ProfilePage({super.key, required this.user, required this.onUserUpdated});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Color(0xFF111111),
        elevation: 0,
        title: Text("Perfil", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // FOTO DE PERFIL -------------------------
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.orange,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundImage: widget.user.photoUrl != null
                          ? NetworkImage(widget.user.photoUrl!)
                          : AssetImage("assets/imgs/profile.jpeg")
                                as ImageProvider,
                    ),
                  ),

                  // ÍCONE DE EDITAR A FOTO
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: changeProfilePicture,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // EMAIL (FIXO)
            Text(
              widget.user.email,
              style: TextStyle(color: Colors.grey[400], fontSize: 15),
            ),

            SizedBox(height: 20),

            // EDITAR USERNAME -------------------------
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nome de usuário",
                labelStyle: TextStyle(color: Colors.orange),
                filled: true,
                fillColor: Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            SizedBox(height: 30),

            // BOTÃO SALVAR -------------------------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: saveProfileChanges,
                child: Text(
                  "Salvar alterações",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),

            SizedBox(height: 40),

            Divider(color: Colors.grey[800]),

            SizedBox(height: 20),

            // BOTÃO LOGOUT -------------------------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: logout,
                child: Text(
                  "Sair da conta",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // FUNÇÕES A IMPLEMENTAR (FAÇO COMPLETA SE QUISER)
  // ========================================================

  void changeProfilePicture() async {
    final picker = ImagePicker();

    // Abrir galeria
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // compressão leve
    );

    if (pickedFile == null) return; // usuário cancelou

    final File file = File(pickedFile.path);

    // Mostrar loading enquanto envia
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    try {
      // Caminho no Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_pictures")
          .child("${widget.user.id}.jpg");

      // Upload do arquivo
      await storageRef.putFile(file);

      // URL final da imagem
      final downloadUrl = await storageRef.getDownloadURL();

      // Atualizar usuário no Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.id)
          .update({"photoUrl": downloadUrl});

      // Atualizar displayName/photoURL do FirebaseAuth (opcional)
      await FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadUrl);

      // Atualiza o estado local
      setState(() {
        widget.user.photoUrl = downloadUrl;
      });

      Navigator.pop(context); // fecha o loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Foto de perfil atualizada!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao atualizar foto: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void saveProfileChanges() async {
    final newName = nameController.text.trim();

    if (newName.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    try {
      // Atualizar no Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.id)
          .update({"name": newName});

      if (widget.user.clanId != null && widget.user.clanId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("clans")
            .doc(widget.user.clanId)
            .collection("members")
            .doc(widget.user.id)
            .update({"name": newName});
      }

      // Atualizar displayName do FirebaseAuth
      await FirebaseAuth.instance.currentUser!.updateDisplayName(newName);

      // Atualizar o objeto local
      setState(() {
        widget.user.name = newName;
      });

      widget.onUserUpdated(widget.user);

      Navigator.pop(context); // fecha loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nome atualizado!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao atualizar nome: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void logout() async {
    // Mostrar diálogo de confirmação
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF111111),
        title: Text("Sair da conta", style: TextStyle(color: Colors.white)),
        content: Text(
          "Tem certeza que deseja sair?",
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Sair", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar indicador de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    try {
      await FirebaseAuth.instance.signOut();

      // Fechar o loading
      Navigator.pop(context);

      // IMPORTANTE: Navegar para AuthPage (que automaticamente mostrará LoginPage)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
        (route) => false,
      );
    } catch (e) {
      // Fechar o loading se houver erro
      if (Navigator.canPop(context)) Navigator.pop(context);

      // Mostrar erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao fazer logout: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
