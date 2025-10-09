import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoadSuccess extends TaskState {
  final List<Task> tasks;
  const TasksLoadSuccess(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskOperationSuccess extends TaskState {
  final Task? task;
  const TaskOperationSuccess([this.task]);

  @override
  List<Object?> get props => [task];
}

class TaskOperationFailure extends TaskState {
  final String message;
  const TaskOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskLoaded extends TaskState {
  final Task task;
  const TaskLoaded(this.task);

  @override
  List<Object?> get props => [task];
}

/// Mục đích: Định nghĩa các TaskState.
/// Vị trí: lib/presentation/blocs/task/task_state.dart

// TODO: Add Task states
