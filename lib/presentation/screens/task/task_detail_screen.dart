// Mục đích: Màn hình chi tiết Task - Logic và State Management
// Vị trí: lib/presentation/screens/task/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/task.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import 'task_detail_ui.dart';

class TaskDetailScreen extends StatelessWidget {
  final String projectId;
  final String taskId;

  const TaskDetailScreen({
    Key? key,
    required this.projectId,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => sl<TaskBloc>()..add(GetTaskByIdRequested(projectId, taskId)),
      child: Scaffold(
        appBar: TaskDetailUIComponents.taskDetailAppBar(title: 'Task Detail'),
        body: const _TaskDetailBody(),
      ),
    );
  }
}

// Widget cho phần body của task detail
class _TaskDetailBody extends StatelessWidget {
  const _TaskDetailBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // Xử lý loading state
        if (state is TaskLoading) {
          return TaskDetailUIComponents.loadingIndicator();
        }

        // Xử lý success state
        if (state is TaskLoaded) {
          final task = state.task;
          return TaskDetailUIComponents.taskDetailContent(
            task: task,
            onToggleCompletion: () => _handleToggleCompletion(context, task),
            onDeleteTask: () => _handleDeleteTask(context, task),
          );
        }

        // Xử lý error state
        if (state is TaskOperationFailure) {
          return TaskDetailUIComponents.errorState(state.message);
        }

        // Default state
        return const SizedBox.shrink();
      },
    );
  }

  // Xử lý toggle completion status
  void _handleToggleCompletion(BuildContext context, Task task) {
    context.read<TaskBloc>().add(
      SetTaskCompletedRequested(task.projectId, task.id, !task.isCompleted),
    );

    // Hiển thị snackbar thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task.isCompleted
              ? 'Task marked as incomplete'
              : 'Task marked as completed',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Xử lý xóa task
  void _handleDeleteTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa task này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  context.read<TaskBloc>().add(
                    DeleteTaskRequested(task.projectId, task.id),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task đã được xóa thành công'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }
}
