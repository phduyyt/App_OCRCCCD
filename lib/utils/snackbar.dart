import 'package:flutter/material.dart';

/// Hàm hiển thị SnackBar tuỳ biến, dùng được trong toàn app.
///
/// [context]: BuildContext hiện tại.
/// [message]: Nội dung cần hiển thị.
/// [backgroundColor]: Màu nền của SnackBar (mặc định: xanh
void showCustomSnackBar(
    BuildContext context,
    String message, {
      Color backgroundColor = Colors.green,
      Duration duration = const Duration(seconds: 1),
    }) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.only(
        bottom: 0,
        left: 16,
        right: 16,
      ),
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
