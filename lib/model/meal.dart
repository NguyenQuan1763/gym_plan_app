class Meal {
  final int? id;
  final String mealType;
  final String foodName;
  final int calories;
  final String note;
  final String date;
  final String time;
  bool completed;

  Meal({
    this.id,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.note,
    required this.date,
    required this.time,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'note': note,
      'date': date,
      'time': time,
      'completed': completed ? 1 : 0,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      mealType: map['mealType'],
      foodName: map['foodName'],
      calories: map['calories'],
      note: map['note'],
      date: map['date'],
      time: map['time'],
      completed: map['completed'] == 1,
    );
  }
}