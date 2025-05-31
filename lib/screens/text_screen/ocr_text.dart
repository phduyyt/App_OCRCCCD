import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:untitled1/screens/text_screen//preview_screen.dart';

class CameraScanText extends StatefulWidget {
  const CameraScanText({Key? key}) : super(key: key);

  @override
  State<CameraScanText> createState() => _CameraScanTextState();
}

class _CameraScanTextState extends State<CameraScanText> {
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
      ResolutionPreset.max,
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
    final fileName = 'text_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = path.join(directory.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(await image.readAsBytes());
    return filePath;
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _capturedImage = pickedFile;
      });

      // Lưu ảnh tạm thời
      final savedPath = await _saveImage(pickedFile);

      // Chuyển hướng đến màn hình preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(imagePath: savedPath),
        ),
      );
    }
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
          'Quét mẫu mới',
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


          // Nút chọn ảnh từ thư viện (góc trái dưới)
          Positioned(
            bottom: 30,
            left: 20, // Đặt ở góc trái
            child: IconButton(
              icon: Icon(
                Icons.image,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _pickImageFromGallery,
            ),
          ),

          // Nút chụp ảnh (chính giữa dưới)
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