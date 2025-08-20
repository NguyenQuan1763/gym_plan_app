import 'package:flutter/material.dart';
import 'package:gym_plan_app/menu_bottom_nav/home_screen.dart';
import '../menu_bottom_nav/add_dialog.dart';
import '../menu_bottom_nav/page_setting.dart';
import '../menu_bottom_nav/page_meal.dart';
import '../menu_bottom_nav/page_workout.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    WorkoutPage(),
    MealPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        shape: CircleBorder(),
        onPressed: () async {
          bool? added = await showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.8),
            builder: (context) => AddDialog(),
          );
          if (added == true && _selectedIndex == 0) {
            setState(() {
              _pages[0] = HomeScreen(); // reload Home
            });
          }
        },
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Color(0x30FFFFFF),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.orange : Colors.grey),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(Icons.fitness_center, color: _selectedIndex == 1 ? Colors.orange : Colors.grey),
                onPressed: () => _onItemTapped(1),
              ),
              SizedBox(width: 40),
              IconButton(
                icon: Icon(Icons.local_pizza, color: _selectedIndex == 2 ? Colors.orange : Colors.grey),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: _selectedIndex == 3 ? Colors.orange : Colors.grey),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
