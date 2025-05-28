import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/screens/cccd_screen/ocr_cccd.dart';
import 'package:untitled1/screens/text_screen/ocr_text.dart';
import 'package:untitled1/screens/table_screens/ocr_table.dart';
import 'package:untitled1/screens/cccd_screen/save_cccd.dart';
import 'package:untitled1/screens/cccd_screen/save_documents.dart';
import 'package:untitled1/screens/userr/user_main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled1/constant/constant.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  String? name;
  int cccdFileCount = 0;
  int documentFileCount = 0;
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadFileCounts();
  }

  void _loadFileCounts() async {
    final cccdCount = await fetchCCCDFileCount();
    final documentCount = await fetchDocumentFileCount();

    setState(() {
      cccdFileCount = cccdCount;
      documentFileCount = documentCount;
    });
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name');
    });
  }

  Future<int> fetchDocumentFileCount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return 0;

    final response = await http.get(Uri.parse('$API_Document_Count?user_id=$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  Future<int> fetchCCCDFileCount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return 0;

    final response = await http.get(Uri.parse('$API_CCCD_Count?user_id=$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    }
    return 0;
  }


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

  Widget _buildScanOption(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          if (label == 'Quét CCCD') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScanCCCD()));
          } else if (label == 'Quét mẫu mới') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScanText()));
          } else if (label == 'Quét dạng bảng') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScanTable()));
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

  // Chỉnh sửa _buildFileCard nhận onTap callback
  Widget _buildFileCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
                  'assets/illustration.png',
                  height: 350,
                  width: double.infinity,
                ),
                SizedBox(height: 20),
                _buildFileCard(
                  Icons.credit_card,
                  'Thông tin CCCD đã lưu',
                  '$cccdFileCount File',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SavedCCCDScreen()),
                    );
                  },
                ),
                SizedBox(height: 12),
                _buildFileCard(
                  Icons.insert_drive_file,
                  'Mẫu đã lưu',
                  '$documentFileCount File',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DocumentListScreen()),
                    );
                  },
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
            SizedBox(width: 10),
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
