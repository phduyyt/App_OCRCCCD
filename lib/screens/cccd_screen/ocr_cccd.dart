import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'preview_screen.dart'; // Import màn hình preview

class CameraScanCCCD extends StatefulWidget {
  const CameraScanCCCD({Key? key}) : super(key: key);

  @override
  State<CameraScanCCCD> createState() => _CameraScanCCCDState();
}

class BorderFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final borderRect = Rect.fromLTWH(40, 100, size.width - 80, size.height - 200);
    final borderRadius = BorderRadius.circular(12);

    final rrect = borderRadius.toRRect(borderRect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraScanCCCDState extends State<CameraScanCCCD> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[0], // Camera sau
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  // Hàm chụp ảnh
  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    try {
      // Chụp ảnh
      final XFile file = await _controller!.takePicture();
      setState(() {
        _capturedImage = file;
      });

      // Lưu ảnh tạm thời
      final savedPath = await _saveImage(file);

      // Chuyển hướng đến màn hình preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(imagePath: savedPath),
        ),
      );
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
    }
  }

  // Hàm lưu ảnh vào thư mục tạm
  Future<String> _saveImage(XFile image) async {
    final directory = await getTemporaryDirectory();
    final fileName = 'cccd_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = path.join(directory.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(await image.readAsBytes());
    return filePath;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F3C88), // Màu nền xanh đậm
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quét CCCD',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isCameraInitialized
          ? Stack(
        children: [
          // Camera preview
          CameraPreview(_controller!),

          // Lớp phủ mờ
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // Khung viền định vị CCCD
          Center(
            child: AspectRatio(
              aspectRatio: 1.6, // Tỷ lệ khung hình của CCCD
              child: CustomPaint(
                painter: BorderFramePainter(),
              ),
            ),
          ),

          // Thông báo hướng dẫn
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Text(
                'Bận vui lòng đặt vị trí CCCD\nkhớp với khung hình',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Nút chụp
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: Colors.black,
                  ),
                  onPressed: _takePicture,
                ),
              ),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}