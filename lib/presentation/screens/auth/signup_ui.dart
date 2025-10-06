// UI Components tập trung cho màn hình đăng ký
// Vị trí: lib/presentation/widgets/signup_ui_components.dart

import 'package:flutter/material.dart';
import '../../share/auth_ui_components.dart';

class SignupUIComponents {
  // Header cho signup screen
  static Widget signupHeader() {
    return AuthUIComponents.authHeader(
      'Đăng Ký',
      'Tạo tài khoản mới để bắt đầu',
    );
  }

  // Form đăng ký
  static Widget signupForm({
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required VoidCallback onSignup,
    required bool isLoading,
  }) {
    return Column(
      children: [
        AuthUIComponents.authTextField(
          controller: nameController,
          label: 'Họ và tên',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
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
          text: 'Đăng Ký',
          onPressed: onSignup,
          isLoading: isLoading,
        ),
      ],
    );
  }

  // Link chuyển sang đăng nhập
  static Widget loginLink({required VoidCallback onTap}) {
    return AuthUIComponents.authSwitchText(
      text: 'Đã có tài khoản?',
      linkText: 'Đăng nhập ngay',
      onTap: onTap,
    );
  }
}