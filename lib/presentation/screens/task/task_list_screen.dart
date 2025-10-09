import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';

/// Mục đích: Màn hình danh sách Task.
/// Vị trí: lib/presentation/screens/task/task_list_screen.dart
class TaskListScreen extends StatelessWidget {
  final String projectId;

  const TaskListScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(LoadTasksRequested(projectId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TasksLoadSuccess) {
              final tasks = state.tasks;
              if (tasks.isEmpty) {
                return const Center(child: Text('No tasks yet'));
              }
              return ListView.separated(
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final t = tasks[index];
                  return ListTile(
                    title: Text(t.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.description),
                        const SizedBox(height: 6),
                        if (t.tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                t.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(tag),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    )
                                    .toList(),
                          ),
                      ],
                    ),
                    trailing:
                        t.isCompleted
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : null,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => TaskDetailScreen(
                                projectId: projectId,
                                taskId: t.id,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            }

            if (state is TaskOperationFailure) {
              return Center(child: Text('Error: ${state.message}'));
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final created = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateTaskScreen(projectId: projectId),
              ),
            );
            if (created == true) {
              // refresh list
              context.read<TaskBloc>().add(LoadTasksRequested(projectId));
            }
          },
        ),
      ),
    );
  }
}
