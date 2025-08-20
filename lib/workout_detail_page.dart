import 'package:flutter/material.dart';
import '../model/workout.dart';
import 'workout_edit_page.dart';
class WorkoutDetailPage extends StatelessWidget {
  final Workout workout;
  final VoidCallback onUpdated;

  const WorkoutDetailPage({
    Key? key,
    required this.workout,
    required this.onUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = isLight ? Colors.orange : const Color(0xFFFF6A00);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Chi tiết bài tập", style: TextStyle(color: isLight ? Colors.black : Colors.white)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: accent,
        elevation: 0,
        iconTheme: IconThemeData(color: isLight ? Colors.black : Colors.white),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                workout.name,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black : Colors.white),
              ),
              const SizedBox(height: 16),

              // Nhóm cơ
              Text("Nhóm cơ: ${workout.muscleGroup}",
                  style: TextStyle(color: accent)),

              const SizedBox(height: 8),

              // Ghi chú
              Text("Ghi chú: ${workout.note}",
                  style: TextStyle(color: isLight ? Colors.black87 : Colors.white)),

              const SizedBox(height: 8),

              // Thời gian
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: accent),
                  const SizedBox(width: 4),
                  Text(workout.time,
                      style: TextStyle(color: isLight ? Colors.black87 : Colors.white)),
                ],
              ),

              const SizedBox(height: 16),

              // Trạng thái hoàn thành
              Text(
                workout.completed ? "Đã hoàn thành" : "Chưa hoàn thành",
                style: TextStyle(
                  color: workout.completed ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Nút chỉnh sửa
              ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutEditPage(workout: workout),
                    ),
                  );
                  if (updated == true) {
                    onUpdated(); // reload lại list
                    Navigator.pop(context); // quay về list
                  }
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.orange : const Color(0xFFFF6A00),
                  minimumSize: const Size(double.infinity, 50),
                ),
                label: const Text("Chỉnh sửa",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
