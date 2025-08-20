import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DatabaseHelper/GymDatabaseHelper.dart';
import '../model/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _avatarPath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
    if (picked != null) {
      setState(() => _avatarPath = picked.path);
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack('Vui lòng nhập đủ thông tin');
      return;
    }
    if (password != confirm) {
      _showSnack('Mật khẩu xác nhận không khớp');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final exists = await GymDatabaseHelper.instance.getUserByEmail(email);
      if (exists != null) {
        _showSnack('Email đã được sử dụng');
        return;
      }
      final user = User(name: name, email: email, password: password, avatar: _avatarPath);
      await GymDatabaseHelper.instance.insertUser(user);
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack('Đăng ký thành công. Vui lòng đăng nhập.');
    } catch (e) {
      _showSnack('Đăng ký thất bại');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Đăng ký', style: TextStyle(color: Colors.white)),
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo app
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      width: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFF1E1E1E),
                        backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                        child: _avatarPath == null
                            ? const Icon(Icons.camera_alt, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInput(_nameController, hint: 'Họ và tên'),
                  const SizedBox(height: 12),
                  _buildInput(_emailController, hint: 'Email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildPassword(_passwordController, hint: 'Mật khẩu', obscure: _obscure1, toggle: () => setState(() => _obscure1 = !_obscure1)),
                  const SizedBox(height: 12),
                  _buildPassword(_confirmController, hint: 'Xác nhận mật khẩu', obscure: _obscure2, toggle: () => setState(() => _obscure2 = !_obscure2)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('TẠO TÀI KHOẢN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // Thêm padding bottom để tránh keyboard
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, {required String hint, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPassword(TextEditingController controller, {required String hint, required bool obscure, required VoidCallback toggle}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}


