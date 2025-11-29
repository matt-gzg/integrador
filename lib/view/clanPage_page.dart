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
            // infos do clã
            StreamBuilder(
              stream: clanStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final clan = snapshot.data!;
                return _buildClanHeader(clan);
              },
            ),

            // membros
            StreamBuilder(
              stream: membersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final members = snapshot.data!;
                return _buildMembersSection(members);
              },
            ),

            // atividades
            StreamBuilder(
              stream: activitiesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
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

  Widget _buildMembersSection(List members) {
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

  Widget _buildActivitiesSection(List activities) {
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
