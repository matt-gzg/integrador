import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/model/clan_model.dart';
import 'package:integrador/model/exercise_model.dart';
import 'package:integrador/services/appUser_service.dart';
import 'package:integrador/services/clan_service.dart';
import 'package:integrador/view/joinApp_page.dart';

class ClanPage extends StatefulWidget {
  final AppUser user;

  const ClanPage({super.key, required this.user});

  @override
  State<ClanPage> createState() => _ClanPageState();
}

class _ClanPageState extends State<ClanPage> {
  late BuildContext parentContext;
  bool _membersExpanded = false; // Alterado para false
  bool _activitiesExpanded = false; // Alterado para false

  // Função para remover um membro do clã (apenas líder)
  void _removeMember(
    BuildContext context,
    String memberId,
    String memberName,
    String clanId,
  ) {
    final stateContext = context;

    showDialog(
      context: stateContext,
      builder: (dialogContext) => Dialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.warning_rounded, color: Colors.red, size: 30),
              ),
              SizedBox(height: 20),

              Text(
                "Remover Membro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              Text(
                "Tem certeza que deseja remover '$memberName' do clã? Esta ação não pode ser desfeita.",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[600]!, width: 1),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red.shade800],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);

                          showDialog(
                            context: stateContext,
                            barrierDismissible: false,
                            useRootNavigator: true,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          );

                          try {
                            final clanService = ClanService();
                            await clanService.removeMember(
                              clanId: clanId,
                              memberId: memberId,
                              leaderId: widget.user.id!,
                            );

                            if (mounted) {
                              Navigator.pop(stateContext); // fecha loading

                              // Se o membro removido for o usuário atual, redireciona
                              if (memberId == widget.user.id) {
                                Navigator.of(stateContext).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const JoinAppPage(),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(stateContext); // fecha loading
                              ScaffoldMessenger.of(stateContext).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao remover membro: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Remover",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  // Função para sair do clã
  void _leaveClan(BuildContext context) {
    final stateContext =
        context; // contexto do State (usado para navegação/mostrar loading)

    showDialog(
      context: stateContext,
      builder: (dialogContext) => Dialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.warning_rounded, color: Colors.red, size: 30),
              ),
              SizedBox(height: 20),

              Text(
                "Sair do Clã",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              Text(
                "Tem certeza que deseja sair do clã? Você perderá todos os pontos e progresso associados.",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[600]!, width: 1),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red.shade800],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          // fecha o diálogo de confirmação
                          Navigator.pop(dialogContext);

                          // abrir loading usando o contexto do State
                          showDialog(
                            context: stateContext,
                            barrierDismissible: false,
                            useRootNavigator: true,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          );

                          try {
                            final clanId = widget.user.clanId!;
                            final userId = widget.user.id!;
                            final clanService = ClanService();
                            final userService = AppUserService();

                            // Verifica se é líder e deleta o clã se necessário
                            await clanService.leaderLeaveClan(
                              clanId: clanId,
                              userId: userId,
                              leaderId: userId,
                            );

                            await userService.updateUser(
                              widget.user.copyWith(clanId: ""),
                            );

                            if (!mounted) return;

                            // fecha loading
                            if (Navigator.canPop(stateContext)) {
                              Navigator.pop(stateContext);
                            }

                            if (!mounted) return;

                            // Navega para JoinAppPage e remove backstack
                            Navigator.of(stateContext).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const JoinAppPage(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            if (!mounted) return;

                            if (Navigator.canPop(stateContext)) {
                              Navigator.pop(stateContext);
                            }

                            if (!mounted) return;

                            ScaffoldMessenger.of(stateContext).showSnackBar(
                              SnackBar(
                                content: Text("Erro ao sair do clã: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Sair",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final clanStream = ClanService().getClan(widget.user.clanId!);
    final activitiesStream = ClanService().getRecentClanExercises(
      widget.user.clanId!,
    );
    final membersStream = ClanService().getClanMembers(widget.user.clanId!);
    parentContext = context;

    // Monitora se o usuário foi removido da subcoleção de membros
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseFirestore.instance
          .collection('clans')
          .doc(widget.user.clanId)
          .collection('members')
          .doc(widget.user.id)
          .snapshots()
          .listen((snapshot) {
            if (!snapshot.exists && mounted) {
              // Usuário foi removido! Redireciona para JoinAppPage
              Navigator.of(context).pushReplacementNamed('/') ??
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const JoinAppPage(),
                    ),
                  );
            }
          });

      // Monitora se o clã foi deletado
      FirebaseFirestore.instance
          .collection('clans')
          .doc(widget.user.clanId)
          .snapshots()
          .listen((snapshot) {
            if (!snapshot.exists && mounted) {
              // Clã foi deletado! Redireciona para JoinAppPage
              Navigator.of(context).pushReplacementNamed('/') ??
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const JoinAppPage(),
                    ),
                  );
            }
          });
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Clã: ${user.clanId}"),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: Icon(Icons.add, color: Colors.deepPurple),
        onPressed: () {
          // registrar atividade
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: clanStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final clan = snapshot.data!;
                return _buildClanHeader(clan);
              },
            ),

            // membros accordion
            StreamBuilder(
              stream: membersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final members = snapshot.data!;
                return _buildMembersAccordion(members);
              },
            ),

            // atividades accordion
            StreamBuilder(
              stream: activitiesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final activities = snapshot.data!;
                return _buildActivitiesAccordion(activities);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClanHeader(clan) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text("Clã ${clan.name}",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Pontos: ${clan.points}",
              style: TextStyle(color: Colors.amber, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildMembersAccordion(List members) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("Membros", style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          SizedBox(height: 10),
          ...members.map((m) => ListTile(
            leading: Icon(Icons.person, color: Colors.deepPurple),
            title: Text(m.name),
            trailing: Text("+${m.points}", style: TextStyle(
              color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _buildActivitiesAccordion(List<Exercise> activities) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("Atividades", style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          SizedBox(height: 10),
          ...activities.map((a) => Card(
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(a.activity),
                  subtitle: Text(a.userName),
                  trailing: Text("+${a.points}",
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold)),
                ),
              )),
        ],
      ),
    );
  }
}
