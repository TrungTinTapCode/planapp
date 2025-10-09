import 'package:bloc/bloc.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../../../domain/usecases/task/create_task.dart';
import '../../../domain/usecases/task/update_task.dart';
import '../../../domain/usecases/task/delete_task.dart';
import '../../../domain/usecases/task/get_tasks_by_project.dart';
import '../../../domain/usecases/task/assign_task.dart';
import '../../../domain/usecases/task/set_task_completed.dart';
import '../../../domain/usecases/task/get_task_by_id.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final GetTasksByProject _getTasksByProject;
  final AssignTask _assignTask;
  final SetTaskCompleted _setTaskCompleted;
  final GetTaskById _getTaskById;

  TaskBloc({
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
    required GetTasksByProject getTasksByProject,
    required AssignTask assignTask,
    required SetTaskCompleted setTaskCompleted,
    required GetTaskById getTaskById,
  }) : _createTask = createTask,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       _getTasksByProject = getTasksByProject,
       _assignTask = assignTask,
       _setTaskCompleted = setTaskCompleted,
       _getTaskById = getTaskById,
       super(TaskInitial()) {
    on<LoadTasksRequested>(_onLoadTasks);
    on<CreateTaskRequested>(_onCreateTask);
    on<UpdateTaskRequested>(_onUpdateTask);
    on<DeleteTaskRequested>(_onDeleteTask);
    on<AssignTaskRequested>(_onAssignTask);
    on<SetTaskCompletedRequested>(_onSetCompleted);
    on<GetTaskByIdRequested>(_onGetById);
  }

  Future<void> _onLoadTasks(
    LoadTasksRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await _getTasksByProject.execute(event.projectId);
      emit(TasksLoadSuccess(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onCreateTask(
    CreateTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final created = await _createTask.execute(event.task);
      emit(TaskOperationSuccess(created));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final updated = await _updateTask.execute(event.task);
      emit(TaskOperationSuccess(updated));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      await _deleteTask.execute(event.projectId, event.taskId);
      emit(const TaskOperationSuccess());
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onAssignTask(
    AssignTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final assigned = await _assignTask.execute(
        event.projectId,
        event.taskId,
        event.assignee,
      );
      emit(TaskOperationSuccess(assigned));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onSetCompleted(
    SetTaskCompletedRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final t = await _setTaskCompleted.execute(
        event.projectId,
        event.taskId,
        event.isCompleted,
      );
      emit(TaskOperationSuccess(t));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  Future<void> _onGetById(
    GetTaskByIdRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final t = await _getTaskById.execute(event.projectId, event.taskId);
      if (t == null) {
        emit(const TaskOperationFailure('Task not found'));
      } else {
        emit(TaskLoaded(t));
      }
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }
}

/// Mục đích: Bloc cho Task.
/// Vị trí: lib/presentation/blocs/task/task_bloc.dart

// TODO: Implement TaskBloc
