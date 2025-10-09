import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';

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
        appBar: AppBar(title: const Text('Task Detail')),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading)
              return const Center(child: CircularProgressIndicator());
            if (state is TaskLoaded) {
              final t = state.task;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(t.description),
                    const SizedBox(height: 8),
                    Text('Deadline: ${t.deadline ?? 'No deadline'}'),
                    const SizedBox(height: 8),
                    Text('Priority: ${t.priority.name}'),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:
                          t.tags.isEmpty
                              ? const Text('No tags')
                              : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    t.tags
                                        .map((tag) => Chip(label: Text(tag)))
                                        .toList(),
                              ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TaskBloc>().add(
                          SetTaskCompletedRequested(
                            projectId,
                            taskId,
                            !t.isCompleted,
                          ),
                        );
                      },
                      child: Text(
                        t.isCompleted
                            ? 'Mark as Incomplete'
                            : 'Mark as Completed',
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is TaskOperationFailure)
              return Center(child: Text('Error: ${state.message}'));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
