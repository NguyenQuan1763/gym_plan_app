import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../DatabaseHelper/GymDatabaseHelper.dart';
import '../model/workout.dart';

class WorkoutEditPage extends StatefulWidget {
  final Workout workout;

  const WorkoutEditPage({Key? key, required this.workout}) : super(key: key);

  @override
  _WorkoutEditScreenState createState() => _WorkoutEditScreenState();
}

class _WorkoutEditScreenState extends State<WorkoutEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  String? selectedMuscleGroup;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // 🔹 Đồng bộ tiếng Anh (lưu trong DB)
  final List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Legs',
    'Abs',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workout.name);
    _noteController = TextEditingController(text: widget.workout.note);
    selectedMuscleGroup = widget.workout.muscleGroup;

    // Parse ngày từ DB
    selectedDate = DateFormat('yyyy-MM-dd').parse(widget.workout.date);

    // Parse giờ từ DB
    final timeParts = widget.workout.time.split(":");
    selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  void _pickDate() async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (datePicked != null) {
      setState(() {
        selectedDate = datePicked;
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (timePicked != null) {
      setState(() {
        selectedTime = timePicked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      selectedDate = null;
    });
  }

  void _clearTime() {
    setState(() {
      selectedTime = null;
    });
  }

  Future<void> _saveChanges() async {
    final db = await GymDatabaseHelper.instance.database;

    final updatedWorkout = {
      'muscleGroup': selectedMuscleGroup ?? widget.workout.muscleGroup,
      'name': _titleController.text,
      'note': _noteController.text,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
      'time': selectedTime != null
          ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"
          : widget.workout.time,
      'completed': widget.workout.completed ? 1 : 0,
    };

    await db.update(
      'workouts',
      updatedWorkout,
      where: 'id = ?',
      whereArgs: [widget.workout.id],
    );

    Navigator.pop(context, true); // trả về true để list refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "Chỉnh sửa bài tập",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.edit, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 10),

                Center(
                  child: Image.asset(
                    "assets/images/workout.png", // hình minh hoạ
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown nhóm cơ
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMuscleGroup,
                      hint: Text("Select muscle group",
                          style: TextStyle(color: Colors.white70)),
                      dropdownColor: Colors.grey[900],
                      style: TextStyle(color: Colors.white),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          selectedMuscleGroup = value;
                        });
                      },
                      items: muscleGroups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tên bài
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Workout name",
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Ghi chú
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Notes...",
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Chọn ngày
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  selectedDate != null
                                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                      : DateFormat('dd/MM/yyyy').format(DateTime.now()),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.orange),
                              onPressed: _clearDate,
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today, color: Colors.orange),
                              onPressed: _pickDate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Chọn giờ
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  selectedTime != null
                                      ? selectedTime!.format(context)
                                      : TimeOfDay.now().format(context),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.orange),
                              onPressed: _clearTime,
                            ),
                            IconButton(
                              icon: Icon(Icons.access_time, color: Colors.orange),
                              onPressed: _pickTime,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Nút lưu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _saveChanges,
                    child: Text(
                      "LƯU",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
