/// UI Components tập trung cho màn hình tạo project
/// Vị trí: lib/presentation/screens/project/create_project_ui.dart

import 'package:flutter/material.dart';

class CreateProjectUI {
  // AppBar cho màn hình tạo project
  static AppBar appBar() {
    return AppBar(
      title: const Text(
        'Tạo dự án mới',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
    );
  }

  // Icon project
  static Widget projectIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.folder_open,
        size: 40,
        color: Colors.blue,
      ),
    );
  }

  // TextField cho tên project
  static Widget nameField({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Tên dự án *',
        hintText: 'Nhập tên dự án...',
        prefixIcon: Icon(Icons.folder),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tên dự án';
        }
        return null;
      },
      maxLength: 50,
    );
  }

  // TextField cho mô tả project
  static Widget descriptionField({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Mô tả',
        hintText: 'Nhập mô tả dự án...',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      maxLength: 200,
    );
  }

  // Nút tạo project
  static Widget createButton({
    required bool isLoading,
    required bool isValid,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isValid ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tạo dự án',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Loading state khi đang tạo project
  static Widget creatingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Đang tạo dự án...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}