import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/services/appUser_service.dart';
import 'package:integrador/view/createClan_page.dart';
import 'package:integrador/view/home_page.dart';
import 'package:integrador/view/joinClan_page.dart';

class JoinAppPage extends StatelessWidget {
  const JoinAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userStream = AppUserService().getUser();

    return StreamBuilder<AppUser?>(
      stream: userStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;

        if (user.clanId == null || user.clanId!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Welcome")),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JoinClanPage(user: user)),
                      );
                    },
                    child: const Text("Join a Clan"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateClanPage(user: user)),
                      );
                    },
                    child: const Text("Create a Clan"),
                  ),
                ],
              ),
            ),
          );
        }

        return HomePage(user: user,);
      },
    );
  }
}
