// Mục đích: UI Components cho màn hình danh sách task
// Vị trí: lib/presentation/screens/task/task_list_ui.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_priority.dart';

class TaskListUIComponents {
  // Header của màn hình task list
  static AppBar taskListAppBar({required String title}) {
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

  // Empty state khi không có task
  static Widget emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first task to get started',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
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
            'Error loading tasks',
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

  // Task list view
  static Widget taskListView({
    required List<Task> tasks,
    required Function(Task) onTaskTap,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return taskItem(
          task: task,
          onTap: () => onTaskTap(task),
        );
      },
    );
  }

  // Task item trong list
  static Widget taskItem({
    required Task task,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildPriorityIndicator(task.priority),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (task.tags.isNotEmpty) _buildTags(task.tags),
            if (task.deadline != null) _buildDeadline(task.deadline!),
          ],
        ),
        trailing: task.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Floating action button để tạo task mới
  static Widget createTaskFAB({required VoidCallback onPressed}) {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
      onPressed: onPressed,
    );
  }
  // Helper: Xây dựng indicator cho priority
  static Widget _buildPriorityIndicator(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.urgent:
        color = Colors.purple;
        break;
      case TaskPriority.high:
        color = Colors.red;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.low:
        color = Colors.green;
        break;
    }
    
    return Container(
      width: 8,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Helper: Xây dựng tags
  static Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags.map((tag) => Chip(
        label: Text(
          tag,
          style: const TextStyle(fontSize: 12),
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      )).toList(),
    );
  }

  // Helper: Xây dựng deadline
  static Widget _buildDeadline(DateTime deadline) {
    final now = DateTime.now();
    final isOverdue = deadline.isBefore(now) && !deadline.isSameDay(now);
    
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: isOverdue ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '${deadline.day}/${deadline.month}/${deadline.year}',
            style: TextStyle(
              fontSize: 12,
              color: isOverdue ? Colors.red : Colors.grey,
              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension helper để so sánh ngày
extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}