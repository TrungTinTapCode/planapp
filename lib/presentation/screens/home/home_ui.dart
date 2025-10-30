// UI Components tập trung cho màn hình home
// Vị trí: lib/presentation/screens/home/home_ui.dart

import 'package:flutter/material.dart';

class HomeUIComponents {
  // AppBar chung cho home
  static AppBar homeAppBar({
    required String title,
    required VoidCallback onLogout,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      bottom: bottom,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
          tooltip: 'Đăng xuất',
        ),
      ],
    );
  }

  // User info widget
  static Widget userInfoCard(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Main content cho home
  static Widget homeContent(String email, bool isLoading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.task_alt, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Chào mừng bạn đến PlanApp 👋',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Quản lý công việc hiệu quả',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          // Hiển thị thông tin user
          if (email.isNotEmpty) ...[
            userInfoCard(email),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 10),
          // Hiển thị loading
          if (isLoading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text('Đang xử lý...'),
          ],
        ],
      ),
    );
  }
}
