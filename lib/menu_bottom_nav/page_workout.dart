import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../DatabaseHelper/GymDatabaseHelper.dart';
import '../Item/WorkoutItem.dart';
import '../model/workout.dart';
import '../workout_detail_page.dart';
import '../add_screen/AddWorkoutScreen.dart';
import 'package:gym_plan_app/workout_edit_page.dart';
import '../onboard/welcome_screen.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  int _selectedDayIndex = 0;
  List<Workout> _workouts = [];
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
    setState(() => _loading = true);

    final targetDate = DateTime.now().add(Duration(days: index));
    final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);

    final workouts = await GymDatabaseHelper().getWorkoutsByDay(dateStr);

    // Sắp xếp: chưa hoàn thành trước, đã hoàn thành xuống cuối; nếu cùng trạng thái thì theo thời gian
    workouts.sort((a, b) {
      if (a.completed == b.completed) {
        return a.time.compareTo(b.time);
      }
      return a.completed ? 1 : -1;
    });

    if (!mounted) return;
    setState(() {
      _selectedDayIndex = index;
      _workouts = workouts;
      _loading = false;
    });
  }

  Future<void> _navigateToAddWorkout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddWorkoutScreen()),
    );

    if (result == true) {
      _loadDataForDay(_selectedDayIndex); // refresh list khi thêm xong
    }
  }

  Future<void> _navigateToEditWorkout(Workout workout) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkoutEditPage(workout: workout)),
    );

    if (result == true) {
      _loadDataForDay(_selectedDayIndex); // refresh list khi sửa xong
    }
  }

  Future<void> _navigateToDetail(Workout workout) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkoutDetailPage(workout: workout, onUpdated: () {  },)),
    );

    if (result == true) {
      _loadDataForDay(_selectedDayIndex); // refresh list khi chỉnh sửa trong detail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                      Text("Hi, $_userName", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Welcome to GymPlanner", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: Colors.grey[900],
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Đăng xuất', style: TextStyle(color: Colors.white)),
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

              // Thanh chọn ngày
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final day = DateTime.now().add(Duration(days: index));
                    final dayLabel = DateFormat('E').format(day);
                    final isSelected = index == _selectedDayIndex;

                    return GestureDetector(
                      onTap: () => _loadDataForDay(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.grey[850],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(dayLabel, style: const TextStyle(color: Colors.white)),
                            Text("${day.day}",
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Danh sách bài tập",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),

              // Danh sách workout
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _workouts.isEmpty
                    ? const Center(
                    child: Text("Không có bài tập",
                        style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  itemCount: _workouts.length,
                  itemBuilder: (context, index) {
                    final w = _workouts[index];
                    return WorkoutItem(
                      workout: w,
                      onUpdated: () => _loadDataForDay(_selectedDayIndex),
                      onEdit: () => _navigateToEditWorkout(w),
                      onOpenDetail: () => _navigateToDetail(w),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
