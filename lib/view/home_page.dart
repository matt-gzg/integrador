import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/view/clanPage_page.dart';
import 'package:integrador/view/exercise_page.dart';
import 'package:integrador/view/profile_page.dart';
import 'package:integrador/view/rank_page.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  late AppUser currentUser;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      RankPage(),
      ClanPage(user: currentUser),
      ExerciseLogPage(user: currentUser),
      ProfilePage(
        user: currentUser,
        onUserUpdated: (updatedUser) {
          setState(() {
            currentUser = updatedUser;
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF111111),
          border: Border(top: BorderSide(color: Colors.grey[800]!, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Color(0xFF111111),
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey[500],
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,

          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 0
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: _selectedIndex == 0 ? 26 : 22,
                ),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.emoji_events_rounded, size: 26),
              ),
              label: "Ranking",
            ),

            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 1
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  size: _selectedIndex == 1 ? 26 : 22,
                ),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.people_alt_rounded, size: 26),
              ),
              label: "Clã",
            ),

            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 2
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: _selectedIndex == 2 ? 26 : 22,
                ),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.fitness_center_rounded, size: 26),
              ),
              label: "Exercícios",
            ),
            
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 3
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: _selectedIndex == 3 ? 26 : 22,
                ),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.person_rounded, size: 26),
              ),
              label: "Perfil",
            ),
          ],
        ),
      ),
    );
  }
}