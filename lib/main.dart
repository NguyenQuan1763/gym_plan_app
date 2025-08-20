import 'package:flutter/material.dart';
import 'package:gym_plan_app/onboard/splash_screen.dart';
import 'theme/theme_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    // await deleteDatabase(join(await getDatabasesPath(), 'gym_app.db')); // Xoá DB cũ

  await ThemeController.instance.load();

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.light),
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
            scaffoldBackgroundColor: Colors.black,
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}
