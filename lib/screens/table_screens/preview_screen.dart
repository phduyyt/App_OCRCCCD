import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:untitled1/screens/table_screens/result_screen.dart';
import 'package:untitled1/constant/constant.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isLoading = false; // Quản lý trạng thái loading

  Future<Map<String, String>?> uploadImageAndGetText(BuildContext context, String imagePath) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(API_Table);
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBodyBytes = await response.stream.toBytes();

        if (responseBodyBytes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dữ liệu trả về từ API rỗng')),
          );
          return null;
        }

        final directory = await getApplicationDocumentsDirectory();
        final now = DateTime.now();
        final formatted = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
        final fileName = 'ocr_result_$formatted.xlsx';
        final filePath = File('${directory.path}/$fileName');
        await filePath.writeAsBytes(responseBodyBytes);

        print('Đã lưu OCR vào file: ${filePath.path}');
        return {'filePath': filePath.path, 'fileName': fileName};
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy dữ liệu, vui lòng thử lại!')),
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
      setState(() {
        _isLoading = false;
      });
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
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null // Disable khi loading
                    : () async {
                  final result = await uploadImageAndGetText(context, widget.imagePath);
                  if (result != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(filePath: result['filePath']!,
                          fileName: result['fileName']!,),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.purple.shade200; // Màu nền khi disabled
                    }
                    return Colors.purpleAccent; // Màu nền khi enabled
                  }),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bo góc tròn
                    ),
                  ),
                  elevation: MaterialStateProperty.resolveWith<double>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return 0; // Không đổ bóng khi disabled
                    }
                    return 6; // Đổ bóng khi enabled
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
