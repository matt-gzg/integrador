import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/model/clan_model.dart';
import 'package:integrador/services/appUser_service.dart';
import 'package:integrador/services/clan_service.dart';
import 'package:integrador/view/createClan_page.dart';
import 'package:integrador/view/home_page.dart';

class ClanListPage extends StatelessWidget {
  final AppUser user;

  const ClanListPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Color(0xFF111111),
        elevation: 0,
        title: Text(
          "Lista de Clãs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateClanPage(user: user)),
          );
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.add_rounded),
        label: Text("Criar Clã", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Cabeçalho informativo
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[800]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Escolha um Clã",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Entre em uma comunidade de competidores e desafie outros clãs!",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Contador de clãs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StreamBuilder<List<Clan>>(
                stream: ClanService().getAllClans(),
                builder: (context, snapshot) {
                  final count = snapshot.hasData ? snapshot.data!.length : 0;
                  return Text(
                    "$count clã${count != 1 ? 's' : ''} disponível${count != 1 ? 's' : ''}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16),

          // Lista de clãs
          Expanded(
            child: StreamBuilder<List<Clan>>(
              stream: ClanService().getAllClans(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Carregando clãs...",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_off_rounded,
                            size: 80,
                            color: Colors.grey[700],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Nenhum clã encontrado",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Seja o primeiro a criar um clã!",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: 200,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.orange.shade800,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreateClanPage(user: user),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "Criar Clã",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final clans = snapshot.data!;

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: clans.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final clan = clans[index];
                    final isLeader = clan.leaderId == user.id;

                    return Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isLeader
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.grey[800]!,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await _joinClan(context, clan);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Ícone do clã
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.flag_rounded,
                                      color: Colors.orange,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),

                                // Informações do clã
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              clan.name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isLeader) ...[
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "LÍDER",
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "Pontuação: ${clan.points} pontos",
                                        style: TextStyle(
                                          color: Colors.orange[300],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Liderado por: ${clan.leaderId == user.id ? 'Você' : 'Outro líder'}",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Ícone de seta
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinClan(BuildContext context, Clan clan) async {
    // Mostrar diálogo de confirmação
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Entrar no Clã",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Você tem certeza que deseja entrar no clã:",
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 10),
                  Text(
                    clan.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Pontuação: ${clan.points} pontos",
              style: TextStyle(color: Colors.orange[300]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade800],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Entrar no Clã",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              SizedBox(height: 16),
              Text("Entrando no clã...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );

    try {
      // 1 — adiciona como membro
      await ClanService().joinClan(clan.id, user.id!, user.name);

      // 2 — atualiza o usuário com o clanId
      final updatedUser = user.copyWith(clanId: clan.id);
      await AppUserService().updateUser(updatedUser);

      // 3 — fecha o loading
      if (context.mounted) Navigator.pop(context);

      // 4 — volta à home
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: updatedUser)),
          (route) => false,
        );
      }
    } catch (e) {
      // Fecha o loading se houver erro
      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao entrar no clã: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
