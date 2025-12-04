import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/task_repository.dart';
import 'kanban_event.dart';
import 'kanban_state.dart';

class KanbanBloc extends Bloc<KanbanEvent, KanbanState> {
  final TaskRepository _taskRepository;
  StreamSubscription<List<Task>>? _sub;

  KanbanBloc({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(KanbanInitial()) {
    on<KanbanStart>(_onStart);
    on<KanbanUpdated>(_onUpdated);
  }

  Future<void> _onStart(KanbanStart event, Emitter<KanbanState> emit) async {
    emit(KanbanLoading());
    await _sub?.cancel();
    _sub = _taskRepository
        .streamTasksAssignedToUser(event.userId)
        .listen(
          (tasks) => add(KanbanUpdated(tasks)),
          onError: (e) {
            emit(KanbanError(e.toString()));
          },
        );
  }

  Future<void> _onUpdated(
    KanbanUpdated event,
    Emitter<KanbanState> emit,
  ) async {
    emit(KanbanLoaded(event.tasks));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
