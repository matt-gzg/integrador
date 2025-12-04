import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
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

                            await clanService.leaveClan(
                              clanId: clanId,
                              userId: userId,
                            );

                            await userService.updateUser(
                              widget.user.copyWith(clanId: ""),
                            );

                            // fecha loading
                            Navigator.of(
                              stateContext,
                              rootNavigator: true,
                            ).pop();

                            if (!mounted) return;

                            // Navega para JoinAppPage e remove backstack
                            Navigator.of(stateContext).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const JoinAppPage(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            Navigator.of(
                              stateContext,
                              rootNavigator: true,
                            ).pop();

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
    final activitiesStream = ClanService().getClanActivities(
      widget.user.clanId!,
    );
    final membersStream = ClanService().getClanMembers(widget.user.clanId!);
    parentContext = context;

    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          "Gym Royale",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Color(0xFF111111),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Icon(
                Icons.exit_to_app_rounded,
                color: Colors.red,
                size: 22,
              ),
            ),
            onPressed: () => _leaveClan(context),
            tooltip: "Sair do Clã",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: clanStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildClanHeaderSkeleton();
                final clan = snapshot.data!;
                return _buildClanHeader(clan);
              },
            ),

            // membros accordion
            StreamBuilder(
              stream: membersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildSectionSkeleton();
                final members = snapshot.data!;
                return _buildMembersAccordion(members);
              },
            ),

            // atividades accordion
            StreamBuilder(
              stream: activitiesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildSectionSkeleton();
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
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF111111)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[800]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícone do clã
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.orange.shade600, Colors.orange.shade800],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(height: 20),

          // Nome do clã
          Text(
            clan.name.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  "PONTUAÇÃO TOTAL",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  clan.points.toString(),
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "pontos",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersAccordion(List members) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: ExpansionTile(
          key: Key('members_accordion'),
          initiallyExpanded: _membersExpanded, // Agora false por padrão
          onExpansionChanged: (expanded) {
            setState(() {
              _membersExpanded = expanded;
            });
          },
          collapsedBackgroundColor: Color(0xFF111111),
          backgroundColor: Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.people_outline,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "MEMBROS",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${members.length}",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          trailing: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Icon(
              _membersExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.orange,
              size: 16,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Column(
                children: members.asMap().entries.map((entry) {
                  final index = entry.key;
                  final m = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade600,
                              Colors.orange.shade800,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        m.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Membro",
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                      trailing: Container(
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
                          "+${m.points}",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesAccordion(List activities) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: ExpansionTile(
          key: Key('activities_accordion'),
          initiallyExpanded: _activitiesExpanded, // Agora false por padrão
          onExpansionChanged: (expanded) {
            setState(() {
              _activitiesExpanded = expanded;
            });
          },
          collapsedBackgroundColor: Color(0xFF111111),
          backgroundColor: Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Icon(Icons.bolt, color: Colors.orange, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "ATIVIDADES RECENTES",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          trailing: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Icon(
              _activitiesExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.orange,
              size: 16,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Column(
                children: activities
                    .map(
                      (a) => Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[800]!,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.assignment_turned_in,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            a.activity,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Por ${a.userName}",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.orange.shade800,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "+${a.points}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClanHeaderSkeleton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 30),
          Container(
            width: 200,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}