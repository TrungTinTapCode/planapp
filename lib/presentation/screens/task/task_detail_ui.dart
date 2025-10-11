// Mục đích: UI Components cho màn hình chi tiết task
// Vị trí: lib/presentation/screens/task/task_detail_ui.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_priority.dart';

class TaskDetailUIComponents {
  // AppBar cho màn hình chi tiết task
  static AppBar taskDetailAppBar({required String title}) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  // Loading indicator
  static Widget loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Error state
  static Widget errorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading task',
            style: TextStyle(fontSize: 18, color: Colors.red[700]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // Main content của task detail
  static Widget taskDetailContent({
    required Task task,
    required VoidCallback onToggleCompletion,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(task),
          const SizedBox(height: 16),
          _buildDescriptionSection(task),
          const SizedBox(height: 16),
          _buildDetailsSection(task),
          const SizedBox(height: 24),
          _buildCompletionButton(task: task, onPressed: onToggleCompletion),
        ],
      ),
    );
  }

  // Section: Tiêu đề task
  static Widget _buildTitleSection(Task task) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriorityBadge(task.priority),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            task.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Section: Mô tả task
  static Widget _buildDescriptionSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            task.description.isEmpty ? 'No description' : task.description,
            style: TextStyle(
              fontSize: 16,
              color: task.description.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Section: Chi tiết task (deadline, tags, assignee)
  static Widget _buildDetailsSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(
          icon: Icons.calendar_today,
          label: 'Deadline',
          value: task.deadline != null 
              ? '${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}'
              : 'No deadline',
          isImportant: task.deadline != null && task.deadline!.isBefore(DateTime.now()),
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          icon: Icons.person,
          label: 'Assignee',
          value: task.assignee?.displayName ?? 'Unassigned',
        ),
        const SizedBox(height: 12),
        _buildTagsSection(task.tags),
      ],
    );
  }

  // Completion toggle button
  static Widget _buildCompletionButton({
    required Task task,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(task.isCompleted ? Icons.refresh : Icons.check),
            const SizedBox(width: 8),
            Text(
              task.isCompleted ? 'Mark as Incomplete' : 'Mark as Completed',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Priority badge
  static Widget _buildPriorityBadge(TaskPriority priority) {
    Color color;
    String label;
    
    switch (priority) {
      case TaskPriority.urgent:
        color = Colors.purple;
        label = 'Urgent';
        break;
      case TaskPriority.high:
        color = Colors.red;
        label = 'High';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case TaskPriority.low:
        color = Colors.green;
        label = 'Low';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper: Detail item với icon
  static Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isImportant = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isImportant ? Colors.red : Colors.black87,
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper: Tags section
  static Widget _buildTagsSection(List<String> tags) {
    if (tags.isEmpty) {
      return _buildDetailItem(
        icon: Icons.local_offer,
        label: 'Tags',
        value: 'No tags',
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.local_offer, size: 20, color: Colors.grey),
            SizedBox(width: 12),
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => Chip(
            label: Text(tag),
            backgroundColor: Colors.blue[50],
          )).toList(),
        ),
      ],
    );
  }
}