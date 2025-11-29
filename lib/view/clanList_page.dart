import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/model/clan_model.dart';
import 'package:integrador/services/appUser_service.dart';
import 'package:integrador/services/clan_service.dart';
import 'package:integrador/view/home_page.dart';

class ClanListPage extends StatelessWidget {
  final AppUser user;

  const ClanListPage({super.key, required this.user});

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
                onTap: () async {
                  try {
                    // 1 — adiciona como membro
                    print("USER ID = ${user.id}");
                    await ClanService().joinClan(
                      clan.id,
                      user.id!,
                      user.name,
                    );

                    // 2 — atualiza o usuário com o clanId
                    final updatedUser = user.copyWith(clanId: clan.id);
                    await AppUserService().updateUser(updatedUser);

                    // 3 — volta à home, que vai carregar ClanHome automaticamente
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage(user: updatedUser)),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro ao entrar no clã: $e")),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
