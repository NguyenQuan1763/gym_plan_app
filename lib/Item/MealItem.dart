import 'package:flutter/material.dart';
import '../model/meal.dart';
import '../DatabaseHelper/GymDatabaseHelper.dart';

class MealItem extends StatelessWidget {
  final Meal meal;
  final VoidCallback onUpdated;
  final VoidCallback onEdit;
  final VoidCallback onOpenDetail;

  const MealItem({
    Key? key,
    required this.meal,
    required this.onUpdated,
    required this.onEdit,
    required this.onOpenDetail,
  }) : super(key: key);

  Future<void> _toggleCompleted() async {
    await GymDatabaseHelper.instance.database.then((db) {
      db.update(
        'meals',
        {'completed': meal.completed ? 0 : 1},
        where: 'id = ?',
        whereArgs: [meal.id],
      );
    });
    onUpdated();
  }

  Future<void> _deleteMeal() async {
    await GymDatabaseHelper.instance.database.then((db) {
      db.delete(
        'meals',
        where: 'id = ?',
        whereArgs: [meal.id],
      );
    });
    onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(meal.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await _deleteMeal();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xoá: ${meal.foodName}")),
        );
      },
      child: GestureDetector(
        onTap: onOpenDetail,
        onLongPress: onEdit,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: meal.completed ? 0.5 : 1.0, // mờ nếu completed
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Phần trái (thông tin món ăn)
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Loại bữa: ${meal.mealType}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Tên món: ${meal.foodName}",
                            style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text("${meal.calories} Kcal",
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Phần phải (ô tick)
                GestureDetector(
                  onTap: _toggleCompleted,
                  child: Container(
                    width: 60,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Icon(
                      meal.completed
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
