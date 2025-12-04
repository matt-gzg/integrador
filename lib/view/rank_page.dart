import 'package:flutter/material.dart';
import 'package:integrador/model/clan_model.dart';
import 'package:integrador/services/clan_service.dart';

class RankPage extends StatelessWidget {
  final ClanService clanService = ClanService();

  RankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Ranking de Clãs",
          style: TextStyle(
            fontSize: 22,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<List<Clan>>(
        stream: clanService.getClansRanked(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final clans = snapshot.data!;

          if (clans.isEmpty) {
            return Center(
              child: Text(
                "Nenhum clã encontrado ainda 👀",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: clans.length,
            itemBuilder: (context, index) {
              final Clan clan = clans[index];
              final position = index + 1;

              Icon? medal;
              if (index == 0) {
                medal = Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                );
              } else if (index == 1) {
                medal = const Icon(
                  Icons.emoji_events,
                  color: Colors.grey,
                  size: 30,
                );
              } else if (index == 2) {
                medal = const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFCD7F32),
                  size: 30,
                );
              }
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF111111),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: ListTile(
                  leading: medal ??
                      CircleAvatar(
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        child: Text(
                          position.toString(),
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  title: Text(
                    clan.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "${clan.points} pontos",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
