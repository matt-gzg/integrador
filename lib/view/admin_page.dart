import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrador/services/clan_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ClanService clanService = ClanService();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Painel do Administrador",
          style: TextStyle(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        // 🔥 BOTÃO DE LOGOUT
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.orange),
            onPressed: () async {
              await auth.signOut();
            },
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("clans")
            .orderBy("points", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum clã encontrado.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final clan = docs[index].data() as Map<String, dynamic>;
              final clanId = docs[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: ListTile(
                  title: Text(
                    clan["name"],
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Pontos: ${clan["points"]}",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 30),
                    onPressed: () => _confirmDelete(context, clanId, clan["name"]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String clanId, String clanName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "Deletar clã",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Tem certeza que deseja deletar o clã \"$clanName\"?\n"
          "Esta ação é permanente.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Deletar", style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.pop(context);
              await clanService.deleteClan(clanId);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Clã \"$clanName\" deletado."),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
