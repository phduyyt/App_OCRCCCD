import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:untitled1/screens/image_ai//result_text_screen.dart';
import 'package:untitled1/constant/constant.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isLoading = false;
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<String?> uploadImageAndGetText(
      BuildContext context, String imagePath, String question) async {
    setState(() => _isLoading = true);

    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh không tồn tại')),
        );
        return null;
      }

      final uri = Uri.parse(API_Text_AI);
      final request = http.MultipartRequest('POST', uri);

      // Thêm file ảnh
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      // Thêm trường question dạng form
      request.fields['question'] = question;

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      if (streamedResponse.statusCode == 200) {
        final responseBodyBytes = await streamedResponse.stream.toBytes();
        final responseBody = utf8.decode(responseBodyBytes);

        if (responseBody.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dữ liệu trả về từ API rỗng')),
          );
          return null;
        }

        final directory = await getApplicationDocumentsDirectory();
        final resultFile = File('${directory.path}/ocr_result.txt');
        await resultFile.writeAsString(responseBody, encoding: utf8);

        print('Đã lưu OCR vào file: ${resultFile.path}');
        return resultFile.path;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API trả về lỗi: ${streamedResponse.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi upload ảnh hoặc lưu file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.imagePath);

    return Scaffold(
      backgroundColor: const Color(0xFF1F3C88),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ảnh đã chụp', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: file.existsSync()
                  ? Image.file(
                file,
                width: double.infinity,
                fit: BoxFit.contain,
              )
                  : const Text('Không tìm thấy ảnh', style: TextStyle(color: Colors.white)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _questionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nhập câu hỏi',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purpleAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                fillColor: Colors.white10,
                filled: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                  final questionText = _questionController.text.trim();
                  if (questionText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập câu hỏi')),
                    );
                    return;
                  }

                  final filePath = await uploadImageAndGetText(
                      context, widget.imagePath, questionText);
                  if (filePath != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultTextScreen(filePath: filePath),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.purple.shade200;
                    }
                    return Colors.purpleAccent;
                  }),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  elevation: MaterialStateProperty.resolveWith<double>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return 0;
                    }
                    return 6;
                  }),
                  shadowColor:
                  MaterialStateProperty.all(Colors.purpleAccent.withOpacity(0.5)),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Tiếp tục',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
