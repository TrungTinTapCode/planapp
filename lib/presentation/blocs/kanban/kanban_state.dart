import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

abstract class KanbanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KanbanInitial extends KanbanState {}

class KanbanLoading extends KanbanState {}

class KanbanLoaded extends KanbanState {
  final List<Task> tasks;
  KanbanLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class KanbanError extends KanbanState {
  final String message;
  KanbanError(this.message);
  @override
  List<Object?> get props => [message];
}
