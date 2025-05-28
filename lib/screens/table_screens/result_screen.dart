import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/constant/constant.dart';

class ResultScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const ResultScreen({Key? key, required this.filePath, required this.fileName}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isProcessing = false;

  String getFileExtension() {
    final ext = widget.fileName.split('.').last;
    return ext.length > 5 ? ext.substring(0, 5) : ext;
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes.bitLength / 10).floor();
    i = i.clamp(0, suffixes.length - 1);
    double size = bytes / (1 << (10 * i));
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  void _openFile(BuildContext context) async {
    final result = await OpenFile.open(widget.filePath);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở file')),
      );
    }
  }

  Future<bool> _saveToDownload(BuildContext context) async {
    // Xin quyền storage (Android)
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn cần cấp quyền lưu trữ để sử dụng chức năng này.')),
      );
      return false;
    }
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final file = File(widget.filePath);
      final newFile = File('${downloadsDir.path}/${widget.fileName}');
      await file.copy(newFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu file vào thư mục Download!')),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu file: $e')),
      );
      return false;
    }
  }

  Future<bool> _uploadFileToServer(BuildContext context) async {
    final apiUrl = API_Save;
    final file = File(widget.filePath);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy user_id. Vui lòng đăng nhập lại!')),
      );
      return false;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['user_id'] = userId.toString()
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final responseBodyBytes = await streamedResponse.stream.toBytes();
      final responseBody = utf8.decode(responseBodyBytes);

      if (streamedResponse.statusCode == 200) {
        final responseJson = jsonDecode(responseBody);
        if (responseJson['message'] == 'File uploaded successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã gửi file lên server thành công!')),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi server: ${responseJson['error'] ?? 'Không rõ lỗi'}')),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi server: ${streamedResponse.statusCode}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi file lên server: $e')),
      );
      return false;
    }
  }

  Future<void> _saveAndUpload(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final saved = await _saveToDownload(context);
      if (!saved) return;
      final uploaded = await _uploadFileToServer(context);
      if (!uploaded) return;
      // Quay lại trang đầu
      Navigator.of(context).popUntil((route) => route.isFirst);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.filePath);
    final fileSize = file.existsSync() ? file.lengthSync() : 0;
    final ext = getFileExtension().toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mẫu trả về'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openFile(context),  // Mở file khi nhấn
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon đuôi file nền tím nhạt viền tím đậm
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        border: Border.all(color: Colors.purple.shade300, width: 1.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '.$ext',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tên file và dung lượng
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.fileName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatBytes(fileSize, 1),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nút chia sẻ nhỏ màu tím đậm
                    IconButton(
                      icon: Icon(Icons.share_outlined, color: Colors.purple.shade700, size: 24),
                      onPressed: _isProcessing ? null : () => Share.shareFiles([widget.filePath]),
                      tooltip: 'Chia sẻ',
                      splashRadius: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _saveAndUpload(context),
                icon: _isProcessing
                    ? SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2,
                  ),
                )
                    : Icon(Icons.save_alt, color: Colors.white),
                label: Text(
                  _isProcessing ? 'Đang xử lý...' : 'Lưu và Gửi lên server',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
                  elevation: MaterialStateProperty.all(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
