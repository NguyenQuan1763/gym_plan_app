import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../DatabaseHelper/GymDatabaseHelper.dart';
import '../model/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? selectedMuscleGroup;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Legs',
    'Abs',
  ];

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

  Future<void> _saveWorkout() async {
    // Kiểm tra validation
    if (selectedMuscleGroup == null || selectedMuscleGroup!.isEmpty) {
      _showSnackBar('Vui lòng chọn nhóm cơ');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập tên bài tập');
      return;
    }

    // Lấy ngày và giờ
    final date = selectedDate ?? DateTime.now();
    final time = selectedTime ?? TimeOfDay.now();
    
    // Format ngày và giờ
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    // Tạo workout object
    final workout = Workout(
      muscleGroup: selectedMuscleGroup!,
      name: _titleController.text.trim(),
      note: _noteController.text.trim(),
      date: dateStr,
      time: timeStr,
      completed: false,
    );

    try {
      // Lưu vào database
      final dbHelper = GymDatabaseHelper();
      await dbHelper.insertWorkout(workout);
      
      // Hiển thị thông báo thành công
      _showSnackBar('Đã thêm bài tập thành công!', isSuccess: true);
      
      // Quay lại màn hình trước
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Có lỗi xảy ra: $e');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black,
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
                      icon: Icon(Icons.arrow_back, color: isLight ? Colors.black : Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "Thêm lịch tập",
                        style: TextStyle(
                          color: isLight ? Colors.black : Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.note_add_outlined, color: isLight ? Colors.black : Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Image
                Center(
                  child: Image.asset(
                    "assets/images/workout.png", // Thay ảnh của bạn vào
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown chọn nhóm cơ
                Container(
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMuscleGroup,
                      hint: Text("Chọn nhóm cơ", style: TextStyle(color: isLight ? Colors.black54 : Colors.white70)),
                      dropdownColor: isLight ? Colors.white : Colors.grey[900],
                      style: TextStyle(color: isLight ? Colors.black : Colors.white),
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
                  style: TextStyle(color: isLight ? Colors.black : Colors.white),
                  decoration: InputDecoration(
                    hintText: "Tên bài",
                    hintStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54),
                    filled: true,
                    fillColor: isLight ? Colors.white : Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Ghi chú
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: TextStyle(color: isLight ? Colors.black : Colors.white),
                  decoration: InputDecoration(
                    hintText: "Ghi chú...",
                    hintStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54),
                    filled: true,
                    fillColor: isLight ? Colors.white : Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isLight ? Colors.grey.shade300 : Colors.transparent),
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
                          color: isLight ? Colors.white : Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
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
                                  style: TextStyle(color: isLight ? Colors.black : Colors.white),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: isLight ? Colors.orange : Color(0xFFFF6A00)),
                              onPressed: _clearDate,
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today, color: isLight ? Colors.orange : Color(0xFFFF6A00)),
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
                          color: isLight ? Colors.white : Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
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
                                  style: TextStyle(color: isLight ? Colors.black : Colors.white),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: isLight ? Colors.orange : Color(0xFFFF6A00)),
                              onPressed: _clearTime,
                            ),
                            IconButton(
                              icon: Icon(Icons.access_time, color: isLight ? Colors.orange : Color(0xFFFF6A00)),
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
                      backgroundColor: isLight ? Colors.orange : Color(0xFFFF6A00),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _saveWorkout,
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
