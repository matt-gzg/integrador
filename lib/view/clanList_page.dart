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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;
    final isLargeScreen = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Color(0xFF111111),
        elevation: 0,
        title: Text(
          "Lista de Clãs",
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 26 : 22,
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
        actions: isTablet
            ? [
                Container(
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade600, Colors.orange.shade800],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateClanPage(user: user),
                        ),
                      );
                    },
                    icon: Icon(Icons.add_rounded, color: Colors.white),
                    label: Text(
                      "Criar Clã",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      floatingActionButton: !isTablet
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateClanPage(user: user),
                  ),
                );
              },
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: Icon(Icons.add_rounded),
              label: Text(
                "Criar Clã",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: Column(
        children: [
          // Cabeçalho informativo
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            margin: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
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
                  padding: EdgeInsets.all(isTablet ? 14 : 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    color: Colors.orange,
                    size: isTablet ? 32 : 28,
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Escolha um Clã",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        "Entre em uma comunidade de competidores e desafie outros clãs!",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),

          // Contador de clãs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StreamBuilder<List<Clan>>(
                stream: ClanService().getAllClans(),
                builder: (context, snapshot) {
                  final count = snapshot.hasData ? snapshot.data!.length : 0;
                  return Text(
                    "$count clã${count != 1 ? 's' : ''} disponível${count != 1 ? 's' : ''}",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: isTablet ? 16 : 14,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Lista de clãs - Layout responsivo
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
                          width: isTablet ? 48 : 40,
                          height: isTablet ? 48 : 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        ),
                        SizedBox(height: isTablet ? 20 : 16),
                        Text(
                          "Carregando clãs...",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 48 : 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_off_rounded,
                            size: isTablet ? 100 : 80,
                            color: Colors.grey[700],
                          ),
                          SizedBox(height: isTablet ? 24 : 20),
                          Text(
                            "Nenhum clã encontrado",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 16 : 12),
                          Text(
                            "Seja o primeiro a criar um clã!",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: isTablet ? 17 : 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 36 : 30),
                          Container(
                            width: isTablet ? 250 : 200,
                            height: isTablet ? 54 : 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.orange.shade800,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
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
                                  borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded,
                                      color: Colors.white,
                                      size: isTablet ? 24 : 20),
                                  SizedBox(width: isTablet ? 10 : 8),
                                  Text(
                                    "Criar Clã",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 16 : 14,
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

                // Layout Grid para tablets e telas grandes
                if (isLargeScreen) {
                  // Para telas muito grandes (desktop ou tablets grandes)
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: 16,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: clans.length,
                    itemBuilder: (context, index) {
                      return _buildClanCard(
                        clans[index],
                        context,
                        isTablet: isTablet,
                      );
                    },
                  );
                } else if (isTablet) {
                  // Para tablets em orientação retrato
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.5,
                    ),
                    itemCount: clans.length,
                    itemBuilder: (context, index) {
                      return _buildClanCard(
                        clans[index],
                        context,
                        isTablet: isTablet,
                      );
                    },
                  );
                } else {
                  // Para smartphones - ListView tradicional
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: 8,
                    ),
                    itemCount: clans.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: isTablet ? 16 : 12),
                    itemBuilder: (context, index) {
                      return _buildClanCard(
                        clans[index],
                        context,
                        isTablet: isTablet,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClanCard(Clan clan, BuildContext context, {bool isTablet = false}) {
    final isLeader = clan.leaderId == user.id;

                                // Informações do clã
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              clan.name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
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

                // Informações do clã
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              clan.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLeader) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 10 : 8,
                                vertical: isTablet ? 4 : 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                              ),
                              child: Text(
                                "LÍDER",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: isTablet ? 11 : 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: isTablet ? 8 : 6),
                      Text(
                        "Pontuação: ${clan.points} pontos",
                        style: TextStyle(
                          color: Colors.orange[300],
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        "Liderado por: ${clan.leaderId == user.id ? 'Você' : 'Outro líder'}",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: isTablet ? 14 : 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ícone de seta
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[600],
                  size: isTablet ? 20 : 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _joinClan(BuildContext context, Clan clan, {bool isTablet = false}) async {
    // Mostrar diálogo de confirmação
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        ),
        title: Text(
          "Entrar no Clã",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Você tem certeza que deseja entrar no clã:",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      clan.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              "Pontuação: ${clan.points} pontos",
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancelar",
              style: TextStyle(
                color: Colors.grey,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade800],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 12 : 10,
                ),
              ),
              child: Text(
                "Entrar no Clã",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 16 : 14,
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
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          decoration: BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: isTablet ? 40 : 32,
                height: isTablet ? 40 : 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              Text(
                "Entrando no clã...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await ClanService().joinClan(
        clan.id,
        user.id!,
        user.name,
      );

      final updatedUser = user.copyWith(clanId: clan.id);
      await AppUserService().updateUser(updatedUser);

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: updatedUser)),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erro ao entrar no clã: $e",
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.all(isTablet ? 20 : 16),
          ),
        );
      }
    }
  }
}