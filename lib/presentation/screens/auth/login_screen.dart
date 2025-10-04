import 'package:flutter/material.dart';

/// Màn hình đăng nhập tạm thời (sẽ thay bằng giao diện thật sau)
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: const Center(
        child: Text('Màn hình đăng nhập'),
      ),
    );
  }
}
