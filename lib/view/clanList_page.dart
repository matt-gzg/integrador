import 'package:flutter/material.dart';
import 'package:integrador/model/clan_model.dart';
import 'package:integrador/services/clan_service.dart';

class ClanListPage extends StatelessWidget {
  const ClanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Clãs"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Clan>>(
        stream: ClanService().getAllClans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Nenhum clã encontrado.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final clans = snapshot.data!;

          return ListView.builder(
            itemCount: clans.length,
            itemBuilder: (context, index) {
              final clan = clans[index];

              return ListTile(
                title: Text(clan.name),
                subtitle: Text("Pontos: ${clan.points}"),
                onTap: () {
                  // aqui você pode navegar para a tela do clã, ou juntar o usuário ao clã
                },
              );
            },
          );
        },
      ),
    );
  }
}
