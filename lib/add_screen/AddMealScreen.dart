import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../DatabaseHelper/GymDatabaseHelper.dart';
import '../model/meal.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedMealType = '';
  String _foodName = '';
  int _calories = 0;
  String _note = '';

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Format thời gian đúng định dạng
      final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      final newMeal = Meal(
        mealType: _selectedMealType,
        foodName: _foodName,
        calories: _calories,
        note: _note,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        time: timeStr,
        completed: false,
      );

      try {
        await GymDatabaseHelper().insertMeal(newMeal);
        _showSnackBar('Meal added successfully!', isSuccess: true);
        Navigator.pop(context, true);
      } catch (e) {
        _showSnackBar('An error occurred: $e');
      }
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
    final accent = isLight ? Colors.orange : const Color(0xFFFF6A00);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLight ? Colors.black : Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thêm bữa ăn',
          style: TextStyle(color: isLight ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/meal.png'), // ảnh minh họa
              ),
              const SizedBox(height: 20),

              // Dropdown bữa ăn
              DropdownButtonFormField<String>(
                dropdownColor: isLight ? Colors.white : Colors.grey[900],
                style: TextStyle(color: isLight ? Colors.black : Colors.white),
                decoration: _inputDecoration('Chọn bữa ăn'),
                value: _selectedMealType.isEmpty ? null : _selectedMealType,
                items: _mealTypes
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedMealType = value ?? ''),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng chọn bữa ăn' : null,
              ),
              const SizedBox(height: 12),

              // Tên món ăn
              TextFormField(
                decoration: _inputDecoration('Tên món ăn'),
                style: TextStyle(color: isLight ? Colors.black : Colors.white),
                onSaved: (val) => _foodName = val!.trim(),
                validator: (val) => val == null || val.isEmpty ? 'Nhập tên món ăn' : null,
              ),
              const SizedBox(height: 12),

              // Lượng calo
              TextFormField(
                decoration: _inputDecoration('Lượng calo'),
                style: TextStyle(color: isLight ? Colors.black : Colors.white),
                keyboardType: TextInputType.number,
                onSaved: (val) => _calories = int.tryParse(val ?? '0') ?? 0,
                validator: (val) => val == null || val.isEmpty ? 'Nhập lượng calo' : null,
              ),
              const SizedBox(height: 12),

              // Ghi chú
              TextFormField(
                decoration: _inputDecoration('Ghi chú...'),
                style: TextStyle(color: isLight ? Colors.black : Colors.white),
                maxLines: 3,
                onSaved: (val) => _note = val ?? '',
              ),
              const SizedBox(height: 12),

              // Chọn ngày
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: TextStyle(color: isLight ? Colors.black : Colors.white),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.clear, color: accent),
                            onPressed: () => setState(() => _selectedDate = DateTime.now()),
                          ),
                          Icon(Icons.calendar_today, color: accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Chọn giờ
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: TextStyle(color: isLight ? Colors.black : Colors.white),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.clear, color: accent),
                            onPressed: () => setState(() => _selectedTime = TimeOfDay.now()),
                          ),
                          Icon(Icons.access_time, color: accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'LƯU',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = isLight ? Colors.orange : const Color(0xFFFF6A00);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white70),
      filled: true,
      fillColor: isLight ? Colors.white : Colors.grey[900],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isLight ? Colors.grey.shade300 : Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent),
      ),
    );
  }
}
