import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;

  // Hàm kiểm tra mật khẩu mới và mật khẩu xác nhận có khớp không
  bool _isPasswordMatch() {
    return _newPasswordController.text == _confirmPasswordController.text;
  }

  // Hàm đổi mật khẩu
  Future<void> _changePassword() async {
    if (!_isPasswordMatch()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu mới và mật khẩu xác nhận không khớp')),
      );
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    // Thực hiện API gọi đổi mật khẩu (có thể là PUT hoặc PATCH request)
    // Giả sử chúng ta gọi API đổi mật khẩu tại đây

    try {
      // Giả lập gửi yêu cầu API đổi mật khẩu (thực tế bạn cần gọi API ở đây)
      await Future.delayed(Duration(seconds: 2));

      // Khi thay đổi thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu đã được thay đổi thành công!')),
      );

      // Quay lại trang UserDetailsScreen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi thay đổi mật khẩu!')),
      );
    } finally {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đổi Mật khẩu'),
        backgroundColor: Color(0xFF1F3C88),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu cũ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40),
            _isChangingPassword
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Đổi mật khẩu', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
