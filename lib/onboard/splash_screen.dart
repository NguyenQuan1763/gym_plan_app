import 'package:flutter/material.dart';
import '../onboard/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../menu_bottom_nav/bottom_nav.dart';


class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 100),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

extension on _SplashScreenState {
  Future<void> _navigate() async {
    await Future.delayed(Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final loggedInEmail = prefs.getString('user_email');
    if (!mounted) return;
    if (loggedInEmail != null && loggedInEmail.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNav()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
    }
  }
}
