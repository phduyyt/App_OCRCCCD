import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled1/constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;
  bool _showPassword = false;
  int? id;
  String? token;
  bool _isPasswordMatch() {
    return _newPasswordController.text == _confirmPasswordController.text;
  }

  Future<void> _changePassword() async {
    if (!_isPasswordMatch()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❗ Mật khẩu xác nhận không khớp')),
      );
      return;
    }
    setState(() {
      _isChangingPassword = true;
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getInt('id');
      token = prefs.getString('access_token');
    });
    final datatosend = {
      'id': id,
      'current_password':_oldPasswordController.text,
      'new_password':_newPasswordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(API_Change_Password),
        headers: {'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
        },
        body: jsonEncode(datatosend),
      );

      final decodebody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodebody);
      print(data['message'] ?? 1 );

      if (response.statusCode == 200) {
        // Nếu đổi mật khẩu thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Đổi mật khẩu thành công')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        // Nếu có lỗi, hiển thị thông báo lỗi từ API
        if (data['status'] == 'error') {
          String errorMessage = data['message'] ?? 'Có lỗi xảy ra!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Lỗi khi thay đổi mật khẩu')),
          );
        }
      }
    } finally {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: () => setState(() => _showPassword = !_showPassword),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Đổi Mật Khẩu', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _oldPasswordController,
              obscureText: !_showPassword,
              decoration: _inputDecoration('Mật khẩu hiện tại'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showPassword,
              decoration: _inputDecoration('Mật khẩu mới'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showPassword,
              decoration: _inputDecoration('Xác nhận mật khẩu mới'),
            ),
            SizedBox(height: 40),
            _isChangingPassword
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _changePassword,
              icon: Icon(Icons.lock_reset),
              label: Text('Xác nhận đổi mật khẩu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFFFF),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
