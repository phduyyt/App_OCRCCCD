import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/constant/constant.dart';
import 'cccd_info_screen.dart'; // Import màn hình thông tin CCCD

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isUploading = false;


  // Hàm gửi ảnh lên API
  Future<Map<String, dynamic>?> _uploadImage(File imageFile) async {
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
        return decodedData; // Trả về dữ liệu OCR
      } else {
        print('Không tìm thấy dữ liệu vui lòng thử lại!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy dữ liệu vui lòng thử lại!')),
        );
        return null;
      }
    } catch (e) {
      print('Lỗi khi upload ảnh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi upload ảnh: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F3C88), // Màu nền xanh đậm
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Ảnh đã chụp',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(
                File(widget.imagePath),
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isUploading
                ? CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isUploading = true;
                });
                final ocrData = await _uploadImage(File(widget.imagePath));
                setState(() {
                  _isUploading = false;
                });

                if (ocrData != null) {
                  // Chuyển hướng đến màn hình thông tin CCCD
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CCCDInfoScreen(ocrData: ocrData),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Tiếp tục',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}