import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksRequested extends TaskEvent {
  final String projectId;
  const LoadTasksRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class CreateTaskRequested extends TaskEvent {
  final Task task;
  const CreateTaskRequested(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskRequested extends TaskEvent {
  final Task task;
  const UpdateTaskRequested(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskRequested extends TaskEvent {
  final String projectId;
  final String taskId;
  const DeleteTaskRequested(this.projectId, this.taskId);

  @override
  List<Object?> get props => [projectId, taskId];
}

class AssignTaskRequested extends TaskEvent {
  final String projectId;
  final String taskId;
  final User? assignee;
  const AssignTaskRequested(this.projectId, this.taskId, this.assignee);

  @override
  List<Object?> get props => [projectId, taskId, assignee];
}

class SetTaskCompletedRequested extends TaskEvent {
  final String projectId;
  final String taskId;
  final bool isCompleted;
  const SetTaskCompletedRequested(
    this.projectId,
    this.taskId,
    this.isCompleted,
  );

  @override
  List<Object?> get props => [projectId, taskId, isCompleted];
}

class GetTaskByIdRequested extends TaskEvent {
  final String projectId;
  final String taskId;
  const GetTaskByIdRequested(this.projectId, this.taskId);

  @override
  List<Object?> get props => [projectId, taskId];
}

/// Mục đích: Định nghĩa các TaskEvent.
/// Vị trí: lib/presentation/blocs/task/task_event.dart

// TODO: Add Task events
