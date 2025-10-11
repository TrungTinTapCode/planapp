// Mục đích: Màn hình danh sách Task - Logic và State Management
// Vị trí: lib/presentation/screens/task/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/task.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';
import 'task_list_ui.dart';

class TaskListScreen extends StatelessWidget {
  final String projectId;

  const TaskListScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(LoadTasksRequested(projectId)),
      child: Scaffold(
        appBar: TaskListUIComponents.taskListAppBar(title: 'Tasks'),
        body: const _TaskListBody(),
        floatingActionButton: const _CreateTaskFAB(),
      ),
    );
  }
}

// Widget cho phần body của task list
class _TaskListBody extends StatelessWidget {
  const _TaskListBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // Xử lý loading state
        if (state is TaskLoading) {
          return TaskListUIComponents.loadingIndicator();
        }

        // Xử lý success state
        if (state is TasksLoadSuccess) {
          final tasks = state.tasks;
          
          // Xử lý empty state
          if (tasks.isEmpty) {
            return TaskListUIComponents.emptyState();
          }

          // Hiển thị danh sách tasks
          return TaskListUIComponents.taskListView(
            tasks: tasks,
            onTaskTap: (task) => _navigateToTaskDetail(context, task),
          );
        }

        // Xử lý error state
        if (state is TaskOperationFailure) {
          return TaskListUIComponents.errorState(state.message);
        }

        // Default state
        return const SizedBox.shrink();
      },
    );
  }

  // Điều hướng đến màn hình chi tiết task
  void _navigateToTaskDetail(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          projectId: task.projectId,
          taskId: task.id,
        ),
      ),
    );
  }
}

// Widget cho Floating Action Button tạo task mới
class _CreateTaskFAB extends StatelessWidget {
  const _CreateTaskFAB();

  @override
  Widget build(BuildContext context) {
    final projectId = (context.findAncestorWidgetOfExactType<TaskListScreen>()?.projectId) ?? '';

    return TaskListUIComponents.createTaskFAB(
      onPressed: () => _navigateToCreateTask(context, projectId),
    );
  }

  // Điều hướng đến màn hình tạo task mới
  void _navigateToCreateTask(BuildContext context, String projectId) async {
    final created = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(projectId: projectId),
      ),
    );
    
    // Refresh list nếu task được tạo thành công
    if (created == true) {
      context.read<TaskBloc>().add(LoadTasksRequested(projectId));
    }
  }
}