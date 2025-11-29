import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/services/clan_service.dart';

class ClanPage extends StatelessWidget {
  final AppUser user;

  const ClanPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final clanStream = ClanService().getClan(user.clanId!);
    final activitiesStream = ClanService().getClanActivities(user.clanId!);
    final membersStream = ClanService().getClanMembers(user.clanId!);

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
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          backgroundColor: Colors.orange,
          elevation: 4,
          child: Icon(Icons.add, color: Colors.black, size: 28),
          onPressed: () {
            // registrar atividade
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // infos do clã
            StreamBuilder(
              stream: clanStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildClanHeaderSkeleton();
                final clan = snapshot.data!;
                return _buildClanHeader(clan);
              },
            ),

            // membros
            StreamBuilder(
              stream: membersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildSectionSkeleton();
                final members = snapshot.data!;
                return _buildMembersSection(members);
              },
            ),

            // atividades
            StreamBuilder(
              stream: activitiesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildSectionSkeleton();
                final activities = snapshot.data!;
                return _buildActivitiesSection(activities);
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
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF111111),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
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
                colors: [
                  Colors.orange.shade600,
                  Colors.orange.shade800,
                ],
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
          
          
          
          // Pontuação elegante
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

  Widget _buildMembersSection(List members) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Icon(Icons.people_outline, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Text(
                  "MEMBROS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${members.length}",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: Column(
              children: members.asMap().entries.map((entry) {
                final index = entry.key;
                final m = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    border: index < members.length - 1 ? Border(
                      bottom: BorderSide(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ) : null,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      width: 44,
                      height: 44,
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
                        size: 20,
                      ),
                    ),
                    title: Text(
                      m.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "Membro",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "+${m.points}",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(List activities) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Icon(Icons.bolt, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Text(
                  "ATIVIDADES RECENTES",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          ...activities.map((a) => Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.assignment_turned_in,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              title: Text(
                a.activity,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Por ${a.userName}",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade600,
                      Colors.orange.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "+${a.points}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )),
          SizedBox(height: 30),
        ],
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