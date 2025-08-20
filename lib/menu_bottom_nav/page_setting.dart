import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboard/welcome_screen.dart';
import '../theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true; // Mặc định là dark mode

  @override
  void initState() {
    super.initState();
    _isDarkMode = ThemeController.instance.themeMode.value == ThemeMode.dark;
    ThemeController.instance.themeMode.addListener(() {
      if (!mounted) return;
      setState(() {
        _isDarkMode = ThemeController.instance.themeMode.value == ThemeMode.dark;
      });
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa tất cả dữ liệu đăng nhập
    
    if (context.mounted) {
      // Chuyển về welcome screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _toggleTheme() {
    ThemeController.instance.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Logo app
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  width: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cài đặt',
                style: TextStyle(color: isLight ? Colors.black : Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Column(
                  children: [
                    // Theme Switch
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: isLight ? Colors.orange : const Color(0xFFFF6A00),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giao diện',
                                  style: TextStyle(
                                    color: isLight ? Colors.black : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _isDarkMode ? 'Chế độ tối' : 'Chế độ sáng',
                                  style: TextStyle(
                                    color: isLight ? Colors.black54 : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isDarkMode,
                            onChanged: (value) => _toggleTheme(),
                            activeColor: isLight ? Colors.orange : const Color(0xFFFF6A00),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Logout Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isLight ? const Color(0xFFFFE5E5) : Colors.red[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isLight ? Colors.red.shade200 : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đăng xuất',
                                  style: TextStyle(
                                    color: isLight ? Colors.black : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Thoát khỏi tài khoản',
                                  style: TextStyle(
                                    color: isLight ? Colors.black54 : Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _logout(context),
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
