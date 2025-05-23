import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ResultTextScreen extends StatelessWidget {
  final String filePath;

  const ResultTextScreen({Key? key, required this.filePath}) : super(key: key);

  // Read file content
  Future<String> _readFile() async {
    final file = File(filePath);
    return await file.readAsString();
  }

  // Save the file to a new location (e.g., downloads folder)
  Future<void> _saveFile(BuildContext context) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      // Get the directory to save the file
      final directory = await getExternalStorageDirectory();
      final newFilePath = '${directory?.path}/ocr_result_downloaded.txt';
      final newFile = File(newFilePath);

      // Write the content to the new file
      await newFile.writeAsString(content);

      // Notify the user that the file has been saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File đã được lưu tại: $newFilePath')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      // Handle error if file could not be saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả OCR'),
      ),
      body: FutureBuilder<String>(
        future: _readFile(),  // Read the file content
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
                      onPressed: () => _saveFile(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Lưu file', style: TextStyle(color: Colors.black)),
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
