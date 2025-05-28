import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled1/constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class ResultTextScreen extends StatefulWidget {
  final String filePath;

  const ResultTextScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  State<ResultTextScreen> createState() => _ResultTextScreenState();
}

class _ResultTextScreenState extends State<ResultTextScreen> {
  bool _isProcessing = false;

  // Read file content
  Future<String> _readFile() async {
    final file = File(widget.filePath);
    return await file.readAsString();
  }

  // Lưu file vào Download và gửi lên server
  Future<void> _saveAndUpload(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy user_id.')),
        );
        return;
      }

      final file = File(widget.filePath);
      final content = await file.readAsString();

      // Tạo tên file theo thời gian
      final now = DateTime.now();
      final formatted =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      final fileName = 'ocr_result_$formatted.txt';

      // Xin quyền lưu vào Download
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn cần cấp quyền lưu trữ để lưu file!')),
        );
        return;
      }

      // Lưu vào Download
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final downloadFile = File('${downloadsDir.path}/$fileName');
      await file.copy(downloadFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu vào thư mục Download: $fileName')),
      );

      // Lưu vào thư mục ứng dụng (nếu cần, để upload)
      final directory = await getExternalStorageDirectory();
      final appFilePath = '${directory?.path}/$fileName';
      final appFile = File(appFilePath);
      await appFile.writeAsString(content);

      // Gửi lên server
      final url = Uri.parse(API_Save);
      var request = http.MultipartRequest('POST', url)
        ..fields['user_id'] = userId.toString()
        ..files.add(await http.MultipartFile.fromPath('file', appFilePath));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBodyBytes = await response.stream.toBytes();
        final responseBody = utf8.decode(responseBodyBytes);
        final responseJson = jsonDecode(responseBody);

        if (responseJson['message'] == 'File uploaded successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload thành công! File URL: ${responseJson['file_url']}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi từ server: ${responseJson['error'] ?? 'Không rõ lỗi'}')),
          );
        }
        // Quay về trang đầu
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối server: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu hoặc upload file: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả OCR'),
      ),
      body: FutureBuilder<String>(
        future: _readFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi đọc file'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có dữ liệu trong file'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.data!, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : () => _saveAndUpload(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Đang lưu & upload...', style: TextStyle(color: Colors.white)),
                        ],
                      )
                          : Text('Lưu vào Download & Gửi lên server', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
