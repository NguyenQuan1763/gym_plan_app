import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../DatabaseHelper/GymDatabaseHelper.dart';
import '../../model/workout.dart';
import '../../model/meal.dart';
import '../../onboard/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDayIndex = 0; // 0 = hôm nay
  List<Workout> _todayWorkouts = [];
  List<Meal> _todayMeals = [];
  bool _loading = true;
  String _userName = '';
  String _userAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDataForDay(_selectedDayIndex);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userAvatar = prefs.getString('user_avatar') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa tất cả dữ liệu đăng nhập
    
    if (!mounted) return;
    
    // Chuyển về welcome screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (route) => false,
    );
  }

  Future<void> _loadDataForDay(int index) async {
    setState(() {
      _loading = true;
    });

    final targetDate = DateTime.now().add(Duration(days: index));
    final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);

    final workouts = await GymDatabaseHelper().getWorkoutsByDay(dateStr);
    final meals = await GymDatabaseHelper().getMealsByDay(dateStr);

    if (!mounted) return;
    setState(() {
      _selectedDayIndex = index;
      _todayWorkouts = workouts;
      _todayMeals = meals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.purple,
                    backgroundImage: _userAvatar.isNotEmpty 
                        ? FileImage(File(_userAvatar))
                        : null,
                    child: _userAvatar.isEmpty 
                        ? const Icon(Icons.person, color: Colors.white, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $_userName",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Welcome to GymPlanner", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: isLight ? Colors.black : Colors.white),
                    color: isLight ? Colors.white : Colors.grey[900],
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: isLight ? Colors.black : Colors.white),
                            SizedBox(width: 8),
                            Text('Đăng xuất', style: TextStyle(color: isLight ? Colors.black : Colors.white)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'logout') {
                        _logout();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Thanh chọn ngày (thứ + ngày)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final day = DateTime.now().add(Duration(days: index));
                    final dayLabel = DateFormat('E').format(day); // Mon, Tue...
                    final isSelected = index == _selectedDayIndex;

                    return GestureDetector(
                      onTap: () => _loadDataForDay(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : (isLight ? Colors.white : Colors.grey[850]),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? null
                              : Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                        ),
                        child: Column(
                          children: [
                            Text(
                              dayLabel,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isLight ? Colors.black : Colors.white),
                              ),
                            ),
                            Text(
                              "${day.day}",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isLight ? Colors.black : Colors.white),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Lịch tập
              Text(
                "Danh sách lịch tập hôm nay",
                style: TextStyle(color: isLight ? Colors.black : Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_todayWorkouts.isEmpty
                    ? Center(child: Text("Không có bài tập", style: TextStyle(color: isLight ? Colors.black54 : Colors.grey)))
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _todayWorkouts.length,
                  itemBuilder: (context, index) {
                    final workout = _todayWorkouts[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nhóm cơ: ${workout.muscleGroup}",
                            style: TextStyle(color: isLight ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Bài tập: ${workout.name}",
                            style: TextStyle(color: isLight ? Colors.black54 : Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(workout.time, style: TextStyle(color: isLight ? Colors.black : Colors.white)),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                )),
              ),

              const SizedBox(height: 20),

              // Bữa ăn
              Text(
                "Danh sách bữa ăn",
                style: TextStyle(color: isLight ? Colors.black : Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_todayMeals.isEmpty
                    ? Center(child: Text("Không có bữa ăn", style: TextStyle(color: isLight ? Colors.black54 : Colors.grey)))
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _todayMeals.length,
                  itemBuilder: (context, index) {
                    final meal = _todayMeals[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Loại bữa: ${meal.mealType}",
                            style: TextStyle(color: isLight ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Tên món: ${meal.foodName}",
                            style: TextStyle(color: isLight ? Colors.black54 : Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text("${meal.calories} Kcal", style: TextStyle(color: isLight ? Colors.black : Colors.white)),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
