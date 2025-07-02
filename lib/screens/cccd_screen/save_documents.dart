import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({Key? key}) : super(key: key);

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  List<Map<String, dynamic>> documents = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        setState(() {
          error = 'Không tìm thấy user_id. Vui lòng đăng nhập lại!';
          isLoading = false;
        });
        return;
      }

      final apiUrl = 'http://192.168.178.78:8000/list_documents_by_user/?user_id=$userId';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          documents = List<Map<String, dynamic>>.from(data['files'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Lỗi khi lấy dữ liệu: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi: $e';
        isLoading = false;
      });
    }
  }

  // Hàm lấy icon dựa trên đuôi file
  Icon _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'xlsx':
        return Icon(Icons.table_chart, color: Colors.green);
      case 'txt':
        return Icon(Icons.description, color: Colors.blue);
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.purple);
    }
  }

  // Hàm hiển thị dialog loading
  void _showLoading(BuildContext context, String? message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            SizedBox(width: 32, height: 32, child: CircularProgressIndicator()),
            SizedBox(width: 20),
            Expanded(child: Text(message ?? 'Đang tải...')),
          ],
        ),
      ),
    );
  }

  // Hàm tải và mở file (có hỏi ghi đè, có loading)
  Future<void> _downloadAndOpenFile(BuildContext context, String url, String fileName) async {
    // Xin quyền storage nếu là Android
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn cần cấp quyền lưu trữ để tải file!')),
      );
      return;
    }

    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final savePath = '${downloadsDir.path}/$fileName';
      final saveFile = File(savePath);

      // Kiểm tra nếu file đã tồn tại
      if (await saveFile.exists()) {
        final overwrite = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('File đã tồn tại'),
            content: Text('Bạn có muốn ghi đè file $fileName không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Không'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Ghi đè'),
              ),
            ],
          ),
        );
        if (overwrite != true) return;
      }

      _showLoading(context, 'Đang tải file...');
      final dio = Dio();
      await dio.download(url, savePath, onReceiveProgress: (count, total) {
        // Có thể cập nhật progress ở đây nếu muốn
      });
      Navigator.of(context, rootNavigator: true).pop(); // Tắt dialog loading

      await OpenFile.open(savePath);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Tắt dialog loading nếu có lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải/mở file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách tài liệu'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!, style: TextStyle(color: Colors.red)))
          : documents.isEmpty
          ? Center(child: Text('Không có tài liệu nào!'))
          : ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: _getFileIcon(doc['file_name'] ?? ''),
              title: Text(doc['file_name'] ?? ''),
              onTap: () async {
                final fileName = doc['file_name'] ?? 'file_download'; 
                final fileUrl = doc['file_url'] ?? '';
                if (fileUrl.isNotEmpty) {
                  await _downloadAndOpenFile(context, fileUrl, fileName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không tìm thấy đường dẫn file!')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
