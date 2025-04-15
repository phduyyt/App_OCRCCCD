import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/screens/userr/user_details.dart';
import 'package:untitled1/screens/userr/change_password.dart';

class UserMainScreen extends StatefulWidget {
  @override
  _UserMainScreenState createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  String? name;
  String? phone;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Tên người dùng';
      phone = prefs.getString('phone') ?? 'Số điện thoại';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xoá toàn bộ dữ liệu
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildTile({required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Thiết lập', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UserDetailsScreen()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(phone ?? '', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          _buildTile(icon: Icons.info_outline, title: 'Quản lý thông tin', onTap: () {
            Navigator.pushNamed(context, '/user-details');
          }),
          _buildTile(icon: Icons.lock, title: 'Đổi mật khẩu', onTap: () {
            Navigator.pushNamed(
              context, '/change-password');
          }),
          _buildTile(icon: Icons.security, title: 'Xác thực 2 bước'),
          _buildTile(icon: Icons.share, title: 'Giới thiệu cho bạn bè'),
          _buildTile(icon: Icons.info, title: 'Thông tin sản phẩm'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.help_outline, color: Colors.blue),
                title: Text("Bạn đang gặp vấn đề cần hỗ trợ?"),
                subtitle: Text("Trung tâm trợ giúp"),
                onTap: () {},
              ),
            ),
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
