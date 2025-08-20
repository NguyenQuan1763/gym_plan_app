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
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black87,
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        shape: CircleBorder(),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.8),
            builder: (context) => AddDialog(),
          );
          if (!mounted) return;
          if (result == 'workout') {
            // Đảm bảo đang ở tab Workout và reload trang
            setState(() {
              _selectedIndex = 1;
              _pages[1] = WorkoutPage(key: UniqueKey());
            });
          } else if (result == 'meal') {
            setState(() {
              _selectedIndex = 2;
              _pages[2] = MealPage(key: UniqueKey());
            });
          }
        },
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: isLight ? Colors.white : const Color(0x30FFFFFF),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.orange : (isLight ? Colors.black54 : Colors.grey)),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(Icons.fitness_center, color: _selectedIndex == 1 ? Colors.orange : (isLight ? Colors.black54 : Colors.grey)),
                onPressed: () => _onItemTapped(1),
              ),
              SizedBox(width: 40),
              IconButton(
                icon: Icon(Icons.local_pizza, color: _selectedIndex == 2 ? Colors.orange : (isLight ? Colors.black54 : Colors.grey)),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: _selectedIndex == 3 ? Colors.orange : (isLight ? Colors.black54 : Colors.grey)),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
