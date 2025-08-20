class Workout {
  final int? id;
  final String muscleGroup;
  final String name;
  final String note;
  final String date;
  final String time;
  bool completed;


  Workout({
    this.id,
    required this.muscleGroup,
    required this.name,
    required this.note,
    required this.date,
    required this.time,
    this.completed = false,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'muscleGroup': muscleGroup,
      'name': name,
      'note': note,
      'date': date,
      'time': time,
      'completed': completed ? 1 : 0,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      muscleGroup: map['muscleGroup'],
      name: map['name'],
      note: map['note'],
      date: map['date'],
      time: map['time'],
      completed: map['completed'] == 1,
    );
  }
}