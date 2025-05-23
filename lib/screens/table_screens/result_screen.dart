import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';  // Cần thêm package này

class ResultScreen extends StatelessWidget {
  final String filePath;
  final String fileName;

  const ResultScreen({Key? key, required this.filePath, required this.fileName}) : super(key: key);

  String getFileExtension() {
    final ext = fileName.split('.').last;
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
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
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
        child: InkWell(
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
                        fileName,
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
                  onPressed: () => Share.shareFiles([filePath]),
                  tooltip: 'Chia sẻ',
                  splashRadius: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
