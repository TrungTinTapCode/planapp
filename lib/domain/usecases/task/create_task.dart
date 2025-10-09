import '../../repositories/task_repository.dart';
import '../../entities/task.dart';

class CreateTask {
  final TaskRepository _repository;

  CreateTask(this._repository);

  Future<Task> execute(Task task) async {
    return await _repository.createTask(task);
  }
}

/// Mục đích: UseCase: Create task.
/// Vị trí: lib/domain/usecases/create_task.dart

// TODO: Implement CreateTask usecase
