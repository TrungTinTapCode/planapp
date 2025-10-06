// UI Components tập trung cho màn hình đăng nhập
// Vị trí: lib/presentation/widgets/login_ui_components.dart

import 'package:flutter/material.dart';
import '../../share/auth_ui_components.dart';

class LoginUIComponents {
  // Header cho login screen
  static Widget loginHeader() {
    return AuthUIComponents.authHeader(
      'Đăng Nhập',
      'Chào mừng bạn quay trở lại',
    );
  }

  // Form đăng nhập
  static Widget loginForm({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required VoidCallback onLogin,
    required bool isLoading,
  }) {
    return Column(
      children: [
        AuthUIComponents.authTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthUIComponents.authTextField(
          controller: passwordController,
          label: 'Mật khẩu',
          icon: Icons.lock,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        AuthUIComponents.authButton(
          text: 'Đăng Nhập',
          onPressed: onLogin,
          isLoading: isLoading,
        ),
      ],
    );
  }

  // Link chuyển sang đăng ký
static Widget registerLink({required VoidCallback onTap}) {
  return AuthUIComponents.authSwitchText(
    text: 'Chưa có tài khoản?',
    linkText: 'Đăng ký ngay',
    onTap: onTap,
  );
}

}