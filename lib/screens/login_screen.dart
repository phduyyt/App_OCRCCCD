import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/constant/constant.dart';
import 'package:untitled1/screens/home_screen.dart';
import 'package:untitled1/screens/signin_screen.dart';
import 'package:untitled1/utils/snackbar.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse(API_Login),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _usernameController.text,
            'password': _passwordController.text,
          }),
        );
        final decodebody = utf8.decode(response.bodyBytes);

        final data = jsonDecode(decodebody);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['tokens']['access']);
          await prefs.setString('refresh_token', data['tokens']['refresh']);

          //Lưu thông tin User
          await prefs.setString('name', data['user']['name']);
          await prefs.setString('email', data['user']['email']);
          await prefs.setString('phone', data['user']['phone']);
          await prefs.setString('address', data['user']['address']);


          showCustomSnackBar(context, 'Đăng nhập thành công!', backgroundColor: Colors.greenAccent);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          showCustomSnackBar(
            context,
            data['message'] ?? 'Tài khoản hoặc mật khẩu không đúng',
            backgroundColor: Colors.redAccent,
          );
        }
      } catch (e) {
        showCustomSnackBar(context, 'Lỗi kết nối: $e', backgroundColor: Colors.redAccent);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 100, color: Colors.deepPurpleAccent),
                  SizedBox(height: 20),
                  Text(
                    'Chào mừng trở lại!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildTextField(
                    controller: _usernameController,
                    icon: Icons.person_outline,
                    label: 'Tên tài khoản',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    label: 'Mật khẩu',
                    obscureText: true,
                  ),
                  SizedBox(height: 40),
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.deepPurpleAccent)
                      : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.deepPurpleAccent,
                      minimumSize: Size(double.infinity, 0),
                      elevation: 5,
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                    ),
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản?',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        ),
                        child: Text(
                          'Đăng ký ngay',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurpleAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        validator: (value) =>
        value!.isEmpty ? 'Vui lòng nhập $label' : null,
      ),
    );
  }
}
