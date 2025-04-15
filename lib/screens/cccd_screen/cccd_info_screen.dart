import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/constant/constant.dart';

class CCCDInfoScreen extends StatefulWidget {
  final Map<String, dynamic> ocrData;

  const CCCDInfoScreen({Key? key, required this.ocrData}) : super(key: key);

  @override
  State<CCCDInfoScreen> createState() => _CCCDInfoScreenState();
}

class _CCCDInfoScreenState extends State<CCCDInfoScreen> {
  late final TextEditingController _idNumberController;
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _genderController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _originPlaceController;
  late final TextEditingController _currentPlaceController;
  late final TextEditingController _expireDateController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _idNumberController = TextEditingController(text: widget.ocrData['id_number'] ?? '');
    _nameController = TextEditingController(text: widget.ocrData['name'] ?? '');
    _dobController = TextEditingController(text: widget.ocrData['dob'] ?? '');
    _genderController = TextEditingController(text: widget.ocrData['gender'] ?? '');
    _nationalityController = TextEditingController(text: widget.ocrData['nationality'] ?? '');
    _originPlaceController = TextEditingController(text: widget.ocrData['origin_place'] ?? '');
    _currentPlaceController = TextEditingController(text: widget.ocrData['current_place'] ?? '');
    _expireDateController = TextEditingController(text: widget.ocrData['expire_date'] ?? '');
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _nationalityController.dispose();
    _originPlaceController.dispose();
    _currentPlaceController.dispose();
    _expireDateController.dispose();
    super.dispose();
  }

  Future<void> _saveDataToApi() async {
    setState(() {
      _isSaving = true;
    });

    final dataToSend = {
      'id_number': _idNumberController.text,
      'name': _nameController.text,
      'dob': _dobController.text,
      'gender': _genderController.text,
      'nationality': _nationalityController.text,
      'origin_place': _originPlaceController.text,
      'current_place': _currentPlaceController.text,
      'expire_date': _expireDateController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(API_CCCD), // <-- Bạn cần định nghĩa API này trong constant.dart
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSend),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu thành công!')),
        );

        // Quay về trang Home (pop đến đầu stack)
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F3C88),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Thông tin CCCD', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEditableField('Số CCCD', _idNumberController),
            _buildEditableField('Họ tên', _nameController),
            _buildEditableField('Ngày sinh', _dobController),
            _buildEditableField('Giới tính', _genderController),
            _buildEditableField('Quốc tịch', _nationalityController),
            _buildEditableField('Quê quán', _originPlaceController),
            _buildEditableField('Nơi thường trú', _currentPlaceController),
            _buildEditableField('Có giá trị đến', _expireDateController),
            const SizedBox(height: 30),
            _isSaving
                ? CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
              onPressed: _saveDataToApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Lưu',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white38),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.purpleAccent),
          ),
        ),
      ),
    );
  }
}
