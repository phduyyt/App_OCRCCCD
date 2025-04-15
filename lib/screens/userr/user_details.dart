import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  String? name, email, phone, address;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Tải thông tin người dùng từ SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name');
      email = prefs.getString('email');
      phone = prefs.getString('phone');
      address = prefs.getString('address');
    });
  }

  // Hàm lưu thông tin cập nhật
  Future<void> _saveUpdatedInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name ?? '');
    await prefs.setString('email', email ?? '');
    await prefs.setString('phone', phone ?? '');
    await prefs.setString('address', address ?? '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cập nhật thông tin thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1F3C88),
        title: Text("Thông tin chi tiết", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile('Tên:', name ?? 'Chưa có tên'),
            _buildInfoTile('Email:', email ?? 'Chưa có email'),
            _buildInfoTile('Số điện thoại:', phone ?? 'Chưa có số điện thoại'),
            _buildInfoTile('Địa chỉ:', address ?? 'Chưa có địa chỉ'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUpdatedInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Cập nhật thông tin', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thông tin
  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
