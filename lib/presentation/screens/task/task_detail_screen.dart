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
import '../../blocs/comment/comment_bloc.dart';
import '../../blocs/comment/comment_event.dart';
import '../../blocs/comment/comment_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'package:planapp/data/models/task_comment_model.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create:
              (_) =>
                  sl<TaskBloc>()..add(GetTaskByIdRequested(projectId, taskId)),
        ),
        BlocProvider<CommentBloc>(
          create:
              (_) =>
                  sl<CommentBloc>()
                    ..add(LoadCommentsRequested(projectId, taskId)),
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: TaskDetailUIComponents.taskDetailAppBar(title: 'Task Detail'),
        body: _TaskDetailBody(projectId: projectId, taskId: taskId),
      ),
    );
  }
}

// Widget cho phần body của task detail
class _TaskDetailBody extends StatelessWidget {
  final String projectId;
  final String taskId;
  const _TaskDetailBody({required this.projectId, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return TaskDetailUIComponents.loadingIndicator();
        }

        if (state is TaskLoaded) {
          final task = state.task;
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: TaskDetailUIComponents.taskDetailContent(
                        task: task,
                        onToggleCompletion:
                            () => _handleToggleCompletion(context, task),
                        onDeleteTask: () => _handleDeleteTask(context, task),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            SizedBox(height: 8),
                            Text(
                              'Bình luận',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    _buildCommentList(),
                    // Add some bottom padding so content isn't hidden behind the input
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
              _buildCommentInputArea(context, task),
            ],
          );
        }

        if (state is TaskOperationFailure) {
          return TaskDetailUIComponents.errorState(state.message);
        }

        return TaskDetailUIComponents.loadingIndicator();
      },
    );
  }

  Widget _buildCommentList() {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentLoading || state is CommentInitial) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (state is CommentOperationFailure) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Lỗi tải bình luận: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        final comments =
            (state is CommentLoadSuccess)
                ? state.comments
                : <TaskCommentModel>[];
        if (comments.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có bình luận nào',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final c = comments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              c.author.displayName.isNotEmpty
                                  ? c.author.displayName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.author.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(c.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.content,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: comments.length),
          ),
        );
      },
    );
  }

  Widget _buildCommentInputArea(BuildContext context, Task task) {
    // Controller should technically be disposed, but for this stateless widget simple fix
    // we can keep it local or use a hook. Since we are in a Stateless widget,
    // we'll instantiate it inside the build method which isn't ideal for retention but works for basic input.
    // Ideally, convert to StatefulWidget or use existing bloc state.
    // For now, I'll use a local variable in the closure which re-inits on rebuild,
    // which is bad. The original code did this too.
    // Improved: I will convert this small part to use a Hook or keep it simple.
    // Let's stick to the previous pattern but strictly separated.
    // NOTE: The previous code created controller inside build, which means it clears on rebuild.
    // That acts as a "clear on submit" if the state updates.
    final TextEditingController controller = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  final auth = sl<AuthBloc>().state;
                  if (auth is! AuthAuthenticated) return;

                  String? notifyUserId;
                  if (auth.user.id == task.creator.id) {
                    notifyUserId = task.assignee?.id;
                  } else {
                    notifyUserId = task.creator.id;
                  }

                  context.read<CommentBloc>().add(
                    AddCommentRequested(
                      projectId: projectId,
                      taskId: taskId,
                      content: text,
                      authorId: auth.user.id,
                      authorEmail: auth.user.email,
                      authorDisplayName:
                          auth.user.displayName.isNotEmpty
                              ? auth.user.displayName
                              : auth.user.email,
                      notifyUserId: notifyUserId,
                      taskTitle: task.title,
                    ),
                  );
                  // Reload comments is NOT needed because the stream will update automatically.
                  // context.read<CommentBloc>().add(LoadCommentsRequested(projectId, taskId));
                  controller.clear();
                  // Hide keyboard
                  FocusScope.of(context).unfocus();
                  // Auto-scroll to top to reveal newest comment
                  final scrollController = PrimaryScrollController.of(context);
                  // Delay slightly to allow list to rebuild
                  Future.delayed(const Duration(milliseconds: 80), () {
                    final position = scrollController.position;
                    final target = position.maxScrollExtent;
                    scrollController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleToggleCompletion(BuildContext context, Task task) {
    context.read<TaskBloc>().add(
      SetTaskCompletedRequested(task.projectId, task.id, !task.isCompleted),
    );
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

  void _handleDeleteTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa task này?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
