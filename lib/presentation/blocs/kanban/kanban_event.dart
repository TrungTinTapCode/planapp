import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

abstract class KanbanEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class KanbanStart extends KanbanEvent {
  final String userId;
  KanbanStart(this.userId);
  @override
  List<Object?> get props => [userId];
}

class KanbanUpdated extends KanbanEvent {
  final List<Task> tasks;
  KanbanUpdated(this.tasks);
  @override
  List<Object?> get props => [tasks];
}
