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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Chi tiết bữa ăn"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                meal.foodName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Loại bữa
              Text("Loại bữa: ${meal.mealType}",
                  style: const TextStyle(color: Colors.orange)),

              const SizedBox(height: 8),

              // Ghi chú
              Text("Ghi chú: ${meal.note}",
                  style: const TextStyle(color: Colors.white)),

              const SizedBox(height: 8),

              // Calo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text("${meal.calories} Kcal",
                      style: const TextStyle(color: Colors.white)),
                ],
              ),

              const SizedBox(height: 8),

              // Thời gian
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(meal.time, style: const TextStyle(color: Colors.white)),
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


