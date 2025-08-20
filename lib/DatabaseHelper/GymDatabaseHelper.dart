import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/workout.dart';
import '../model/meal.dart';
import 'package:intl/intl.dart';
import '../model/user.dart';

class GymDatabaseHelper {
  GymDatabaseHelper._internal();
  static final GymDatabaseHelper instance = GymDatabaseHelper._internal();
  factory GymDatabaseHelper() => instance;

  Database? _db;

  // ====== Meal option pools (deterministic per-date selection) ======
  static const List<Map<String, dynamic>> _breakfastOptions = [
    {'foodName': 'Oatmeal + banana', 'calories': 350, 'note': 'No sugar'},
    {'foodName': 'Boiled eggs + toast', 'calories': 300, 'note': '2 eggs'},
    {'foodName': 'Greek yogurt + berries', 'calories': 280, 'note': 'No sugar'},
    {'foodName': 'Smoothie (banana + spinach)', 'calories': 320, 'note': 'No sugar'},
    {'foodName': 'Avocado toast', 'calories': 350, 'note': 'Whole grain bread'},
    {'foodName': 'Cereal + milk', 'calories': 300, 'note': 'Low fat milk'},
    {'foodName': 'Protein shake', 'calories': 280, 'note': 'Whey protein'},
    {'foodName': 'Pho ga', 'calories': 380, 'note': 'Ít muối'},
    {'foodName': 'Banh mi trung', 'calories': 330, 'note': 'Ít bơ'},
  ];

  static const List<Map<String, dynamic>> _lunchOptions = [
    {'foodName': 'Grilled chicken + rice', 'calories': 600, 'note': 'Brown rice'},
    {'foodName': 'Beef steak + salad', 'calories': 650, 'note': 'Medium rare'},
    {'foodName': 'Chicken curry + rice', 'calories': 700, 'note': 'Homemade'},
    {'foodName': 'Pasta + tomato sauce', 'calories': 600, 'note': 'Olive oil'},
    {'foodName': 'Salmon sushi', 'calories': 500, 'note': 'Fresh'},
    {'foodName': 'Chicken sandwich', 'calories': 450, 'note': 'Whole wheat bread'},
    {'foodName': 'Roast beef + mashed potato', 'calories': 650, 'note': 'Homemade'},
    {'foodName': 'Bun thit nuong', 'calories': 620, 'note': 'Ít mỡ'},
    {'foodName': 'Com tam suon', 'calories': 680, 'note': 'Ít mỡ'},
  ];

  static const List<Map<String, dynamic>> _dinnerOptions = [
    {'foodName': 'Salmon + veggies', 'calories': 500, 'note': 'Low salt'},
    {'foodName': 'Tuna + sweet potato', 'calories': 450, 'note': '1 medium'},
    {'foodName': 'Shrimp + broccoli', 'calories': 480, 'note': 'Steamed'},
    {'foodName': 'Grilled chicken salad', 'calories': 420, 'note': 'Light'},
    {'foodName': 'Beef + stir-fry vegetables', 'calories': 550, 'note': 'Soy sauce'},
    {'foodName': 'Grilled fish + spinach', 'calories': 480, 'note': 'Olive oil'},
    {'foodName': 'Chicken soup + bread', 'calories': 420, 'note': 'Light'},
    {'foodName': 'Bun bo Hue', 'calories': 560, 'note': 'Ít gia vị'},
    {'foodName': 'Mi xao bo', 'calories': 520, 'note': 'Ít dầu'},
  ];

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'gym_app.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        avatar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        muscleGroup TEXT,
        name TEXT,
        note TEXT,
        date TEXT,
        time TEXT,
        completed INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mealType TEXT,
        foodName TEXT,
        calories INTEGER,
        note TEXT,
        date TEXT,
        time TEXT,
        completed INTEGER
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_workouts_date ON workouts(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(date)');

    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workouts_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          muscleGroup TEXT,
          name TEXT,
          note TEXT,
          date TEXT,
          time TEXT,
          completed INTEGER
        )
      ''');

      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='workouts'");
      if (tables.isNotEmpty) {
        try {
          await db.execute('''
            INSERT INTO workouts_new(time, completed)
            SELECT time, completed FROM workouts
          ''');
        } catch (_) {}
        await db.execute('DROP TABLE workouts');
      }

      await db.execute('ALTER TABLE workouts_new RENAME TO workouts');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_workouts_date ON workouts(date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(date)');

      final cnt = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM workouts WHERE date IS NOT NULL"),
      ) ??
          0;
      if (cnt == 0) {
        await _insertDefaultData(db);
      }
    }

    if (oldVersion < 3) {
      // Upgrade users schema: from (name, phone) -> (name, email, password, avatar)
      final hasUsers = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='users'");
      if (hasUsers.isNotEmpty) {
        await db.execute('DROP TABLE IF EXISTS users');
      }
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          avatar TEXT
        )
      ''');
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    DateTime now = DateTime.now();

    // === BÀI TẬP ===
    Map<String, List<Map<String, String>>> workoutPlans = {
      'Chest': [
        {'name': 'Bench Press', 'note': '3 sets x 12 reps'},
        {'name': 'Incline Dumbbell Press', 'note': '3 sets x 10 reps'},
        {'name': 'Push-up', 'note': '4 sets x 15 reps'},
        {'name': 'Cable Fly', 'note': '3 sets x 12 reps'},
        {'name': 'Chest Dip', 'note': '3 sets x 8 reps'},
      ],
      'Back': [
        {'name': 'Pull-up', 'note': '4 sets x 8 reps'},
        {'name': 'Bent-over Row', 'note': '4 sets x 10 reps'},
        {'name': 'Lat Pulldown', 'note': '3 sets x 12 reps'},
        {'name': 'Seated Row', 'note': '3 sets x 12 reps'},
        {'name': 'Deadlift', 'note': '3 sets x 8 reps'},
      ],
      'Legs': [
        {'name': 'Squat', 'note': '4 sets x 10 reps'},
        {'name': 'Lunges', 'note': '3 sets x 12 reps each leg'},
        {'name': 'Leg Press', 'note': '4 sets x 10 reps'},
        {'name': 'Leg Curl', 'note': '3 sets x 12 reps'},
        {'name': 'Calf Raise', 'note': '4 sets x 15 reps'},
      ],
      'Shoulders': [
        {'name': 'Overhead Press', 'note': '3 sets x 12 reps'},
        {'name': 'Lateral Raise', 'note': '3 sets x 15 reps'},
        {'name': 'Front Raise', 'note': '3 sets x 15 reps'},
        {'name': 'Rear Delt Fly', 'note': '3 sets x 12 reps'},
        {'name': 'Arnold Press', 'note': '3 sets x 10 reps'},
      ],
      'Arms': [
        {'name': 'Bicep Curl', 'note': '3 sets x 15 reps'},
        {'name': 'Hammer Curl', 'note': '3 sets x 15 reps'},
        {'name': 'Tricep Pushdown', 'note': '3 sets x 12 reps'},
        {'name': 'Skull Crusher', 'note': '3 sets x 10 reps'},
        {'name': 'Close-grip Bench Press', 'note': '3 sets x 10 reps'},
      ],
      'Abs': [
        {'name': 'Plank', 'note': '3 sets x 1 min hold'},
        {'name': 'Crunch', 'note': '3 sets x 20 reps'},
        {'name': 'Leg Raise', 'note': '3 sets x 15 reps'},
        {'name': 'Bicycle Crunch', 'note': '3 sets x 20 reps'},
        {'name': 'Mountain Climber', 'note': '3 sets x 30 secs'},
      ],
      'Full Body': [
        {'name': 'Burpee', 'note': '3 sets x 15 reps'},
        {'name': 'Kettlebell Swing', 'note': '3 sets x 20 reps'},
        {'name': 'Thruster', 'note': '3 sets x 12 reps'},
        {'name': 'Clean and Press', 'note': '3 sets x 8 reps'},
        {'name': 'Jump Squat', 'note': '3 sets x 15 reps'},
      ],
    };

    List<String> muscleGroups = workoutPlans.keys.toList();

    // === ĐỒ ĂN ===: loại bỏ seed cố định theo Day1..Day7

    // === LẶP 7 NGÀY ===
    for (int i = 0; i < 7; i++) {
      DateTime targetDate = now.add(Duration(days: i));
      String dateStr = DateFormat('yyyy-MM-dd').format(targetDate);

      // --- Thêm bài tập ---
      String todayMuscle = muscleGroups[i % muscleGroups.length];
      for (var plan in workoutPlans[todayMuscle]!) {
        await db.insert('workouts', {
          'muscleGroup': todayMuscle,
          'name': plan['name'],
          'note': plan['note'],
          'date': dateStr,
          'time': '08:00',
          'completed': 0
        });
      }

      // --- Thêm meal (3 bữa/ngày, mỗi ngày khác nhau, không lặp) ---
      // Chọn options theo chỉ số ngày để đảm bảo khác nhau theo ngày và không lặp trong cùng ngày
      final breakfastIdx = i % _breakfastOptions.length;
      final lunchIdx = (i * 3 + 1) % _lunchOptions.length;
      final dinnerIdx = (i * 5 + 2) % _dinnerOptions.length;

      final breakfast = _breakfastOptions[breakfastIdx];
      final lunch = _lunchOptions[lunchIdx];
      final dinner = _dinnerOptions[dinnerIdx];

      final mealsForDay = [
        {'mealType': 'Breakfast', ...breakfast, 'time': '07:00'},
        {'mealType': 'Lunch', ...lunch, 'time': '12:00'},
        {'mealType': 'Dinner', ...dinner, 'time': '18:00'},
      ];

      for (final meal in mealsForDay) {
        await db.insert('meals', {
          'mealType': meal['mealType'],
          'foodName': meal['foodName'],
          'calories': meal['calories'],
          'note': meal['note'],
          'date': dateStr,
          'time': meal['time'],
          'completed': 0,
        });
      }
    }
  }

  // ===== Users =====
  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  Future<User?> authenticate(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return db.insert('workouts', workout.toMap());
  }

  Future<int> insertMeal(Meal meal) async {
    final db = await database;
    return db.insert('meals', meal.toMap());
  }

  Future<List<Workout>> getWorkoutsByDay(String day) async {
    final db = await database;
    final res = await db.query('workouts', where: 'date = ?', whereArgs: [day]);
    return res
        .map((e) => Workout.fromMap(e))
        .toList();
  }

  Future<List<Meal>> getMealsByDay(String day) async {
    final db = await database;
    // Đảm bảo luôn có 3 món cho ngày yêu cầu, mỗi ngày khác nhau
    final existing = await db.query('meals', where: 'date = ?', whereArgs: [day]);
    if (existing.length < 3) {
      // Xoá dữ liệu cũ của ngày (nếu có) để tránh lẫn
      await db.delete('meals', where: 'date = ?', whereArgs: [day]);

      // Tạo lại 3 món theo thuật toán chọn chỉ số dựa trên ngày
      final dateObj = DateTime.parse(day);
      final dayOffset = dateObj.difference(DateTime(DateTime.now().year)).inDays;

      final breakfastIdx = (dayOffset) % _breakfastOptions.length;
      final lunchIdx = (dayOffset * 3 + 1) % _lunchOptions.length;
      final dinnerIdx = (dayOffset * 5 + 2) % _dinnerOptions.length;

      final breakfast = _breakfastOptions[breakfastIdx];
      final lunch = _lunchOptions[lunchIdx];
      final dinner = _dinnerOptions[dinnerIdx];

      final mealsForDay = [
        {'mealType': 'Breakfast', ...breakfast, 'time': '07:00'},
        {'mealType': 'Lunch', ...lunch, 'time': '12:00'},
        {'mealType': 'Dinner', ...dinner, 'time': '18:00'},
      ];

      for (final meal in mealsForDay) {
        await db.insert('meals', {
          'mealType': meal['mealType'],
          'foodName': meal['foodName'],
          'calories': meal['calories'],
          'note': meal['note'],
          'date': day,
          'time': meal['time'],
          'completed': 0,
        });
      }
    }
    final res = await db.query('meals', where: 'date = ?', whereArgs: [day]);
    return res
        .map((e) => Meal.fromMap(e))
        .toList();
  }

  // Cập nhật Workout
  Future<int> updateWorkout(Workout workout) async {
    final db = await database;
    return db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

// Xoá Workout
  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
// Cập nhật Meal
  Future<int> updateMeal(Meal meal) async {
    final db = await database;
    return db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

// Xoá Meal
  Future<int> deleteMeal(int id) async {
    final db = await database;
    return db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== Helper methods for meal options =====
  static List<Map<String, dynamic>> getBreakfastOptions() {
    return _breakfastOptions;
  }

  static List<Map<String, dynamic>> getLunchOptions() {
    return _lunchOptions;
  }

  static List<Map<String, dynamic>> getDinnerOptions() {
    return _dinnerOptions;
  }

  static List<Map<String, dynamic>> getMealOptionsByType(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return _breakfastOptions;
      case 'lunch':
        return _lunchOptions;
      case 'dinner':
        return _dinnerOptions;
      default:
        return _breakfastOptions;
    }
  }

  // ===== Helper methods for workout options =====
  static List<String> getMuscleGroups() {
    return ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Abs', 'Full Body'];
  }

  static List<Map<String, String>> getWorkoutsByMuscleGroup(String muscleGroup) {
    Map<String, List<Map<String, String>>> workoutPlans = {
      'Chest': [
        {'name': 'Bench Press', 'note': '3 sets x 12 reps'},
        {'name': 'Incline Dumbbell Press', 'note': '3 sets x 10 reps'},
        {'name': 'Push-up', 'note': '4 sets x 15 reps'},
        {'name': 'Cable Fly', 'note': '3 sets x 12 reps'},
        {'name': 'Chest Dip', 'note': '3 sets x 8 reps'},
      ],
      'Back': [
        {'name': 'Pull-up', 'note': '4 sets x 8 reps'},
        {'name': 'Bent-over Row', 'note': '4 sets x 10 reps'},
        {'name': 'Lat Pulldown', 'note': '3 sets x 12 reps'},
        {'name': 'Seated Row', 'note': '3 sets x 12 reps'},
        {'name': 'Deadlift', 'note': '3 sets x 8 reps'},
      ],
      'Legs': [
        {'name': 'Squat', 'note': '4 sets x 10 reps'},
        {'name': 'Lunges', 'note': '3 sets x 12 reps each leg'},
        {'name': 'Leg Press', 'note': '4 sets x 10 reps'},
        {'name': 'Leg Curl', 'note': '3 sets x 12 reps'},
        {'name': 'Calf Raise', 'note': '4 sets x 15 reps'},
      ],
      'Shoulders': [
        {'name': 'Overhead Press', 'note': '3 sets x 12 reps'},
        {'name': 'Lateral Raise', 'note': '3 sets x 15 reps'},
        {'name': 'Front Raise', 'note': '3 sets x 15 reps'},
        {'name': 'Rear Delt Fly', 'note': '3 sets x 12 reps'},
        {'name': 'Arnold Press', 'note': '3 sets x 10 reps'},
      ],
      'Arms': [
        {'name': 'Bicep Curl', 'note': '3 sets x 15 reps'},
        {'name': 'Hammer Curl', 'note': '3 sets x 15 reps'},
        {'name': 'Tricep Pushdown', 'note': '3 sets x 12 reps'},
        {'name': 'Skull Crusher', 'note': '3 sets x 10 reps'},
        {'name': 'Close-grip Bench Press', 'note': '3 sets x 10 reps'},
      ],
      'Abs': [
        {'name': 'Plank', 'note': '3 sets x 1 min hold'},
        {'name': 'Crunch', 'note': '3 sets x 20 reps'},
        {'name': 'Leg Raise', 'note': '3 sets x 15 reps'},
        {'name': 'Bicycle Crunch', 'note': '3 sets x 20 reps'},
        {'name': 'Mountain Climber', 'note': '3 sets x 30 secs'},
      ],
      'Full Body': [
        {'name': 'Burpee', 'note': '3 sets x 15 reps'},
        {'name': 'Kettlebell Swing', 'note': '3 sets x 20 reps'},
        {'name': 'Thruster', 'note': '3 sets x 12 reps'},
        {'name': 'Clean and Press', 'note': '3 sets x 8 reps'},
        {'name': 'Jump Squat', 'note': '3 sets x 15 reps'},
      ],
    };
    
    return workoutPlans[muscleGroup] ?? [];
  }

}
