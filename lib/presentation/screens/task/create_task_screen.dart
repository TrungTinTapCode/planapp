// Mục đích: Màn hình tạo task mới - Logic và State Management
// Vị trí: lib/presentation/screens/task/create_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_priority.dart';
import '../../../domain/entities/user.dart';
import '../../../data/models/user_model.dart';
import '../../../data/datasources/firebase/project_service.dart';
import 'create_task_ui.dart';

class CreateTaskScreen extends StatefulWidget {
  final String projectId;

  const CreateTaskScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  DateTime? _deadline;
  TaskPriority _priority = TaskPriority.medium;
  final List<String> _tags = [];
  List<User> _members = []; // ✅ ĐỔI THÀNH List<User>
  User? _selectedAssignee; // ✅ ĐỔI THÀNH User

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Tải danh sách thành viên trong project và convert sang User entity
  Future<void> _loadMembers() async {
    try {
      final projectService = sl<ProjectService>();
      final users = await projectService.getMembers(widget.projectId);
      setState(() {
        // ✅ CONVERT UserModel sang User
        _members = users.map((u) {
          final userModel = UserModel.fromJson(u);
          return User(
            id: userModel.id,
            displayName: userModel.displayName,
            email: userModel.email,
          );
        }).toList();
      });
    } catch (error) {
      print('Error loading members: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>(),
      child: Scaffold(
        appBar: CreateTaskUIComponents.createTaskAppBar(),
        body: BlocListener<TaskBloc, TaskState>(
          listener: (context, state) {
            _handleTaskState(context, state);
          },
          child: _buildContent(),
        ),
      ),
    );
  }

  // Xây dựng nội dung chính
  Widget _buildContent() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final isLoading = state is TaskLoading;

        return CreateTaskUIComponents.createTaskForm(
          formKey: _formKey,
          titleController: _titleController,
          descriptionController: _descriptionController,
          deadline: _deadline,
          priority: _priority,
          members: _members, // ✅ TRUYỀN List<User>
          selectedAssignee: _selectedAssignee, // ✅ TRUYỀN User
          tags: _tags,
          tagsController: _tagsController,
          onDeadlineChanged: _handleDeadlineChanged,
          onPriorityChanged: _handlePriorityChanged,
          onAssigneeChanged: _handleAssigneeChanged,
          onTagAdded: _handleTagAdded,
          onTagRemoved: _handleTagRemoved,
          onCreateTask: () => _handleCreateTask(context),
          isLoading: isLoading,
          context: context,
        );
      },
    );
  }

  // Xử lý thay đổi deadline
  void _handleDeadlineChanged(DateTime? deadline) {
    setState(() {
      _deadline = deadline;
    });
  }

  // Xử lý thay đổi priority
  void _handlePriorityChanged(TaskPriority priority) {
    setState(() {
      _priority = priority;
    });
  }

  // Xử lý thay đổi assignee
  void _handleAssigneeChanged(User? assignee) {
    setState(() {
      _selectedAssignee = assignee;
    });
  }

  // Xử lý thêm tag
  void _handleTagAdded(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  // Xử lý xóa tag
  void _handleTagRemoved(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  // Xử lý tạo task
  void _handleCreateTask(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final task = _createTaskEntity();
      context.read<TaskBloc>().add(CreateTaskRequested(task));
    }
  }

  // Tạo entity task từ form data
  Task _createTaskEntity() {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: widget.projectId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _deadline,
      tags: List.from(_tags),
      priority: _priority,
      assignee: _selectedAssignee, // ✅ SỬ DỤNG TRỰC TIẾP User
      createdAt: DateTime.now(),
      creator: const User(
        id: 'current_user', // Sẽ được thay thế bằng user thực tế
        displayName: 'Current User',
        email: 'current@user.com',
      ),
    );
  }

  // Xử lý state từ TaskBloc
  void _handleTaskState(BuildContext context, TaskState state) {
    if (state is TaskOperationSuccess) {
      // Trở về màn hình trước với kết quả thành công
      Navigator.of(context).pop(true);
      
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state is TaskOperationFailure) {
      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}