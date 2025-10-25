// UI Components tập trung cho các màn hình authentication
// Vị trí: lib/presentation/widgets/auth_ui_components.dart

import 'package:flutter/material.dart';

class AuthUIComponents {
  // Header chung cho auth screens
  static Widget authHeader(String title, String subtitle) {
    return Column(
      children: [
        const Icon(Icons.task_alt, size: 80, color: Colors.blue),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 30),
      ],
    );
  }

  // TextField chung cho auth
  static Widget authTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint, // ✅ THÊM PARAMETER HINT
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint, // ✅ SỬ DỤNG HINT
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Button chung cho auth
  static Widget authButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // Link chuyển sang login/register
  static Widget authSwitchText({
    required String text,
    required String linkText,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
