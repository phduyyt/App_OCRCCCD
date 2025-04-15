import 'package:flutter/material.dart';
import 'package:untitled1/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingScreen extends StatefulWidget {
  @override
  State<UserSettingScreen> createState() => _UserSettingScreenState();
}
class _UserSettingScreenState extends State<UserSettingScreen> {
  int _selectedIndex = 2;
  String? name ;
  String? phone ;

  @override
  void initState(){
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name');
    });
  }

  // Xử lý khi nhấn vào các mục trên thanh điều hướng
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Xin Chào',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
            color: Colors.black,
          ),
        ],
      ),



      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Color(0xFF1F3C88) : Colors.grey,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            SizedBox(width: 10), // Khoảng cách cho nút quét ở giữa
            IconButton(
              icon: Icon(
                Icons.person,
                color: _selectedIndex == 2 ? Color(0xFF1F3C88) : Colors.grey,
              ),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo thẻ tệp (File Card)
  Widget _buildFileCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFD6D9F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color(0xFF1F3C88)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}