import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/screens/cccd_screen/ocr_cccd.dart';
import 'package:untitled1/screens/cccd_screen/save_cccd.dart'; // Import màn hình SavedCCCDScreen
import 'package:untitled1/screens/userr/user_main.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  String? name;

  @override
  void initState() {
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
    if (index == 1) {
      _showScanOptions();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserMainScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Hiển thị popup với các tùy chọn quét
  void _showScanOptions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Các tùy chọn quét',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 15),
              _buildScanOption(Icons.perm_identity, 'Quét CCCD'),
              _buildScanOption(Icons.file_copy, 'Quét mẫu có sẵn'),
              _buildScanOption(Icons.note_add, 'Quét mẫu mới'),
              _buildScanOption(Icons.table_chart, 'Quét dạng bảng'),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tạo nút tùy chọn quét trong popup
  Widget _buildScanOption(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context); // Đóng popup
          if (label == 'Quét CCCD') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScanCCCD()));
          }
        },
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1F3C88),
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // Widget tạo thẻ tệp (File Card)
  Widget _buildFileCard(IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        // Khi người dùng nhấn vào thẻ "Thông tin CCCD đã lưu"
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SavedCCCDScreen()), // Điều hướng đến màn hình danh sách CCCD
        );
      },
      child: Container(
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
      ),
    );
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Image.asset(
                  'assets/illustration.png', // Đảm bảo đường dẫn hình ảnh đúng
                  height: 350,
                  width: double.infinity,
                ),
                SizedBox(height: 20),
                _buildFileCard(
                  Icons.credit_card,
                  'Thông tin CCCD đã lưu',
                  '5 File', // Số lượng file có thể lấy từ API hoặc SharedPreferences
                ),
                SizedBox(height: 12),
                _buildFileCard(
                  Icons.insert_drive_file,
                  'Mẫu đã lưu',
                  '22 File', // Số lượng mẫu có thể lấy từ API hoặc SharedPreferences
                ),
              ],
            ),
          ),
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(1),
        backgroundColor: Color(0xFF1F3C88),
        child: Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
