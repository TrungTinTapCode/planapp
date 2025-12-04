import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../blocs/kanban/kanban_bloc.dart';
import '../../../blocs/kanban/kanban_event.dart';
import '../../../blocs/kanban/kanban_state.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../../domain/entities/task.dart';
import 'package:planapp/domain/entities/task_priority.dart';
import '../../../screens/task/task_detail_screen.dart';
import '../../../blocs/task/task_bloc.dart';
import '../../../blocs/task/task_event.dart';
import '../../../blocs/task/task_state.dart';

class KanbanBoardWidget extends StatelessWidget {
  const KanbanBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<KanbanBloc>(create: (context) => sl<KanbanBloc>()),
        BlocProvider<TaskBloc>(create: (context) => sl<TaskBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => curr is AuthAuthenticated,
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final kb = context.read<KanbanBloc>();
            if (kb.state is KanbanInitial) {
              kb.add(KanbanStart(state.user.id));
            }
          }
        },
        child: BlocListener<TaskBloc, TaskState>(
          listenWhen: (prev, curr) => curr is TaskOperationSuccess,
          listener: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is AuthAuthenticated) {
              context.read<KanbanBloc>().add(KanbanStart(auth.user.id));
            }
          },
          child: Builder(
            builder: (context) {
              final auth = context.read<AuthBloc>().state;
              final kb = context.read<KanbanBloc>();
              if (auth is AuthAuthenticated && kb.state is KanbanInitial) {
                kb.add(KanbanStart(auth.user.id));
              }
              return const _KanbanContent();
            },
          ),
        ),
      ),
    );
  }
}

class _KanbanContent extends StatelessWidget {
  const _KanbanContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KanbanBloc, KanbanState>(
      builder: (context, state) {
        if (state is KanbanLoading || state is KanbanInitial) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is KanbanError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Lỗi tải bảng Kanban: ${state.message}'),
          );
        }
        final tasks = (state is KanbanLoaded) ? state.tasks : <Task>[];
        final todo = tasks.where((t) => t.status == TaskStatus.todo).toList();
        final inProgress =
            tasks.where((t) => t.status == TaskStatus.inProgress).toList();
        final done = tasks.where((t) => t.status == TaskStatus.done).toList();

        return SizedBox(
          height: 280,
          child: Row(
            children: [
              Expanded(
                child: _KanbanColumn(
                  title: 'Cần làm',
                  items: todo,
                  targetStatus: TaskStatus.todo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KanbanColumn(
                  title: 'Đang làm',
                  items: inProgress,
                  targetStatus: TaskStatus.inProgress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KanbanColumn(
                  title: 'Đã xong',
                  items: done,
                  targetStatus: TaskStatus.done,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final List<Task> items;
  final TaskStatus targetStatus;
  const _KanbanColumn({
    required this.title,
    required this.items,
    required this.targetStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 22,
                constraints: const BoxConstraints(minWidth: 22),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(11),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                child: Text(
                  '${items.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: DragTarget<Task>(
              onWillAccept: (data) => true,
              onAccept: (task) {
                context.read<TaskBloc>().add(
                  SetTaskStatusRequested(task.projectId, task.id, targetStatus),
                );
              },
              builder: (context, candidateData, rejectedData) {
                final highlight = candidateData.isNotEmpty;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: highlight ? Colors.blueAccent : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      items.isEmpty
                          ? Center(
                            child: Text(
                              'Trống',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                          : ListView.separated(
                            primary: false,
                            physics: const ClampingScrollPhysics(),
                            dragStartBehavior: DragStartBehavior.down,
                            padding: EdgeInsets.zero,
                            itemCount: items.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final task = items[i];
                              return _KanbanCard(task: task);
                            },
                          ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Task task;
  const _KanbanCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      maxSimultaneousDrags: 1,
      hapticFeedbackOnStart: true,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: _CardVisual(task: task, elevation: 6),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: _CardVisual(task: task)),
      onDragStarted: () {},
      onDragEnd: (_) {},
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => TaskDetailScreen(
                    projectId: task.projectId,
                    taskId: task.id,
                  ),
            ),
          );
        },
        child: _CardVisual(task: task),
      ),
    );
  }

  // Removed unused private relative method (moved to _CardVisual.relative)
}

class _CardVisual extends StatelessWidget {
  final Task task;
  final double elevation;
  const _CardVisual({required this.task, this.elevation = 2});

  static String relative({required DateTime deadline}) {
    final diff = deadline.difference(DateTime.now());
    if (diff.inDays >= 1) return '${diff.inDays} ngày nữa';
    if (diff.inHours >= 1) return '${diff.inHours} giờ nữa';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} phút nữa';
    return 'Sắp đến hạn';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _priorityColor(task), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0x11000000),
            blurRadius: elevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          if (task.deadline != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    _CardVisual.relative(deadline: task.deadline!),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _priorityColor(Task task) {
    // Ánh xạ màu viền theo priority
    switch (task.priority) {
      case TaskPriority.urgent:
        return Colors.redAccent;
      case TaskPriority.high:
        return Colors.deepOrangeAccent;
      case TaskPriority.medium:
        return Colors.amber.shade700;
      case TaskPriority.low:
        return Colors.green.shade600;
    }
  }
}
