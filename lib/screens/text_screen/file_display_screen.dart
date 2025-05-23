import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileDisplayScreen extends StatelessWidget {
  final String fileContent;

  const FileDisplayScreen({Key? key, required this.fileContent}) : super(key: key);

  Future<void> _saveToFile(BuildContext context) async {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/text_result_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(filePath);
      await file.writeAsString(fileContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu file tại: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nội dung văn bản'),
        backgroundColor: Color(0xFF1F3C88),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _saveToFile(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            fileContent,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
