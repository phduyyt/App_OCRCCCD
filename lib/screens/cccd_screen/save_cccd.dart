import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/constant/constant.dart';
import 'package:untitled1/screens/cccd_screen/cccd_detail.dart';

class SavedCCCDScreen extends StatefulWidget {
  @override
  _SavedCCCDScreenState createState() => _SavedCCCDScreenState();
}

class _SavedCCCDScreenState extends State<SavedCCCDScreen> {
  List<Map<String, String>> cccdList = [];

  @override
  void initState() {
    super.initState();
    _loadCCCDList();
  }

  // Lấy user_id từ SharedPreferences và gọi API
  Future<void> _loadCCCDList() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');  // Lấy user_id từ SharedPreferences

    if (userId != null) {
      // Gửi yêu cầu HTTP GET đến API để lấy danh sách CCCD của người dùng
      final response = await http.get(
        Uri.parse('$API_Get_CCCD_ByID?user_id=$userId'),  // Thêm user_id vào URL query parameters
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodebody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodebody);

        // Giả sử API trả về danh sách CCCD dưới dạng một list trong trường 'cccds'
        setState(() {
          // Lấy dữ liệu và chuyển thành danh sách
          cccdList = List<Map<String, String>>.from(data['cccds'].map((item) {
            return {
              'cccd_id': item['id']?.toString() ?? "",
              'id_number': item['id_number']?.toString() ?? 'Chưa có số CCCD',
              'name': item['name']?.toString() ?? 'Chưa có tên',
              'dob': item['dob']?.toString() ?? 'Chưa có ngày sinh',
              'gender': item['gender']?.toString() ?? 'Chưa có giới tính',
              'nationality': item['nationality']?.toString() ?? 'Chưa có quốc tịch',
              'origin_place': item['origin_place']?.toString() ?? 'Chưa có quê quán',
              'current_place': item['current_place']?.toString() ?? 'Chưa có địa chỉ',
              'expire_date': item['expire_date']?.toString() ?? 'Chưa có ngày hết hạn',
            };
          }));
        });
      } else {
        // Xử lý khi API trả về lỗi
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu CCCD')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1F3C88),
        title: Text("Chọn thông tin", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: cccdList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: cccdList.length,
        itemBuilder: (context, index) {
          final item = cccdList[index];
          print(item);
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.credit_card, color: Color(0xFF1F3C88)),
              title: Text(item['name'] ?? 'Chưa có tên'),  // Cập nhật kiểm tra null cho name
              subtitle: Text(item['id_number'] ?? 'Chưa có số CCCD'),  // Cập nhật kiểm tra null cho cccd
              trailing: Icon(Icons.arrow_forward, color: Color(0xFF1F3C88)),
              onTap: () {
                // Điều hướng đến màn hình chi tiết thông tin CCCD
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CCCDDetailScreen(Data: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
