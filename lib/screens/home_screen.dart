import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/constant/constant.dart';
import 'dart:io';
import 'dart:convert';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // Để lưu ảnh đã chụp

  // Hàm chụp ảnh và gửi ảnh
  Future<void> _takePicture() async {
    try {
      final pickedImage = await _picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
        print('Đường dẫn ảnh: ${_image!.path}');

        // Gửi ảnh tới API
        await _uploadImage(File(_image!.path));
      }
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
    }
  }

  // Hàm gửi ảnh tới API
  Future<void> _uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(API_Ocr);
      final request = http.MultipartRequest('POST', url);

      // Thêm file vào request
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Tên field trong body API
        imageFile.path,
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);
        print('Upload thành công: $decodedData');

        // Giải mã JSON

        // Xử lý phản hồi từ server (nếu cần)
      } else {
        print('Upload thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi upload ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Chào mừng đến với ứng dụng'),
            SizedBox(height: 20),
            _image != null
                ? Image.file(File(_image!.path), width: 200, height: 200)
                : Text('Chưa có ảnh nào được chụp'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePicture,
              child: Text('Chụp ảnh'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Xóa token khi logout
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('access_token');
                await prefs.remove('refresh_token');

                // Quay về màn hình login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              },
              child: Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
