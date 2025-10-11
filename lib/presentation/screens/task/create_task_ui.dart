// Mục đích: UI Components cho màn hình tạo task mới
// Vị trí: lib/presentation/screens/task/create_task_ui.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/task_priority.dart';
import '../../../data/models/user_model.dart';

class CreateTaskUIComponents {
  // AppBar cho màn hình tạo task
  static AppBar createTaskAppBar() {
    return AppBar(
      title: const Text('Create Task'),
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

  // Main form để tạo task
  static Widget createTaskForm({
    required GlobalKey<FormState> formKey,
    required TextEditingController titleController,
    required TextEditingController descriptionController,
    required DateTime? deadline,
    required TaskPriority priority,
    required List<UserModel> members,
    required UserModel? selectedAssignee,
    required List<String> tags,
    required TextEditingController tagsController,
    required Function(DateTime?) onDeadlineChanged,
    required Function(TaskPriority) onPriorityChanged,
    required Function(UserModel?) onAssigneeChanged,
    required Function(String) onTagAdded,
    required Function(String) onTagRemoved,
    required VoidCallback onCreateTask,
    required bool isLoading,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleField(titleController),
              const SizedBox(height: 16),
              _buildDescriptionField(descriptionController),
              const SizedBox(height: 16),
              _buildDeadlineField(deadline: deadline, onChanged: onDeadlineChanged),
              const SizedBox(height: 16),
              _buildPriorityField(priority: priority, onChanged: onPriorityChanged),
              const SizedBox(height: 16),
              if (members.isNotEmpty) 
                _buildAssigneeField(
                  members: members,
                  selectedAssignee: selectedAssignee,
                  onChanged: onAssigneeChanged,
                ),
              const SizedBox(height: 16),
              _buildTagsField(
                tags: tags,
                tagsController: tagsController,
                onTagAdded: onTagAdded,
                onTagRemoved: onTagRemoved,
              ),
              const SizedBox(height: 24),
              _buildCreateButton(
                onCreateTask: onCreateTask,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Title field
  static Widget _buildTitleField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Title *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
    );
  }

  // Description field
  static Widget _buildDescriptionField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      textAlignVertical: TextAlignVertical.top,
    );
  }

  // Deadline field
  static Widget _buildDeadlineField({
    required DateTime? deadline,
    required Function(DateTime?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              deadline == null 
                  ? 'Select deadline' 
                  : '${deadline.day}/${deadline.month}/${deadline.year}',
              style: TextStyle(
                color: deadline == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: _getCurrentContext(),
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
          ),
          if (deadline != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () => onChanged(null),
            ),
        ],
      ),
    );
  }

  // Priority field
  static Widget _buildPriorityField({
    required TaskPriority priority,
    required Function(TaskPriority) onChanged,
  }) {
    return DropdownButtonFormField<TaskPriority>(
      value: priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag),
      ),
      items: TaskPriority.values.map((priority) {
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
        
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(priority.name.toUpperCase()),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => onChanged(value ?? TaskPriority.medium),
    );
  }

  // Assignee field
  static Widget _buildAssigneeField({
    required List<UserModel> members,
    required UserModel? selectedAssignee,
    required Function(UserModel?) onChanged,
  }) {
    return DropdownButtonFormField<UserModel?>(
      value: selectedAssignee,
      decoration: const InputDecoration(
        labelText: 'Assignee',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      items: [
        const DropdownMenuItem<UserModel?>(
          value: null,
          child: Text('Unassigned'),
        ),
        ...members.map((user) => DropdownMenuItem<UserModel?>(
          value: user,
          child: Text(user.displayName),
        )).toList(),
      ],
      onChanged: onChanged,
    );
  }

  // Tags field
  static Widget _buildTagsField({
    required List<String> tags,
    required TextEditingController tagsController,
    required Function(String) onTagAdded,
    required Function(String) onTagRemoved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...tags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () => onTagRemoved(tag),
            )).toList(),
            SizedBox(
              width: 150,
              child: TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  hintText: 'Add tag...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onSubmitted: (value) {
                  final tag = value.trim();
                  if (tag.isNotEmpty) {
                    onTagAdded(tag);
                    tagsController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Create button
  static Widget _buildCreateButton({
    required VoidCallback onCreateTask,
    required bool isLoading,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: isLoading ? null : onCreateTask,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Text(
              'Create Task',
              style: TextStyle(fontSize: 16),
            ),
    );
  }

  // Helper để lấy context (cần cho showDatePicker)
  static BuildContext _getCurrentContext() {
    return navigatorKey.currentContext!;
  }
}

// Global key cho navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();