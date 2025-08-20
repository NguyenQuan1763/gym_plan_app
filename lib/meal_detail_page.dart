import 'package:flutter/material.dart';
import 'model/meal.dart';

class MealDetailPage extends StatelessWidget {
  final Meal meal;
  final VoidCallback onUpdated;

  const MealDetailPage({
    Key? key,
    required this.meal,
    required this.onUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = isLight ? Colors.orange : const Color(0xFFFF6A00);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Chi tiết bữa ăn", style: TextStyle(color: isLight ? Colors.black : Colors.white)),
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
                meal.foodName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLight ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Loại bữa
              Text("Loại bữa: ${meal.mealType}",
                  style: TextStyle(color: accent)),

              const SizedBox(height: 8),

              // Ghi chú
              Text("Ghi chú: ${meal.note}",
                  style: TextStyle(color: isLight ? Colors.black87 : Colors.white)),

              const SizedBox(height: 8),

              // Calo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department, color: accent),
                  const SizedBox(width: 4),
                  Text("${meal.calories} Kcal",
                      style: TextStyle(color: isLight ? Colors.black87 : Colors.white)),
                ],
              ),

              const SizedBox(height: 8),

              // Thời gian
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: accent),
                  const SizedBox(width: 4),
                  Text(meal.time, style: TextStyle(color: isLight ? Colors.black87 : Colors.white)),
                ],
              ),

              const SizedBox(height: 16),

              // Trạng thái
              Text(
                meal.completed ? "Đã ăn xong" : "Chưa ăn",
                style: TextStyle(
                  color: meal.completed ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


