import 'package:flutter/material.dart';
import '../model/workout.dart';
import '../DatabaseHelper/GymDatabaseHelper.dart';

class WorkoutItem extends StatelessWidget {
  final Workout workout;
  final VoidCallback onUpdated;
  final VoidCallback onEdit;
  final VoidCallback onOpenDetail;

  const WorkoutItem({
    Key? key,
    required this.workout,
    required this.onUpdated,
    required this.onEdit,
    required this.onOpenDetail,
  }) : super(key: key);

  Future<void> _toggleCompleted() async {
    await GymDatabaseHelper.instance.database.then((db) {
      db.update(
        'workouts',
        {'completed': workout.completed ? 0 : 1},
        where: 'id = ?',
        whereArgs: [workout.id],
      );
    });
    onUpdated();
  }

  Future<void> _deleteWorkout() async {
    await GymDatabaseHelper.instance.database.then((db) {
      db.delete(
        'workouts',
        where: 'id = ?',
        whereArgs: [workout.id],
      );
    });
    onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dismissible(
      key: Key(workout.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await _deleteWorkout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xoá: ${workout.name}")),
        );
      },
      child: GestureDetector(
        onTap: onOpenDetail, // mở trang chi tiết khi bấm
        onLongPress: onEdit, // sửa khi giữ
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: workout.completed ? 0.5 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Phần trái
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nhóm cơ: ${workout.muscleGroup}",
                            style: TextStyle(
                                color: isLight ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Bài tập: ${workout.name}",
                            style: TextStyle(color: isLight ? Colors.black54 : Colors.grey)),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(workout.time,
                                style: TextStyle(color: isLight ? Colors.black : Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Phần phải (ô tick) - bấm để toggle completed
                GestureDetector(
                  onTap: _toggleCompleted,
                  child: Container(
                    width: 60,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: isLight ? Colors.orange : const Color(0xFFFF6A00),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Icon(
                      workout.completed
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
