import '../../repositories/task_repository.dart';
import '../../entities/task.dart';

class UpdateTask {
  final TaskRepository _repository;

  UpdateTask(this._repository);

  Future<Task> execute(Task task) async {
    return await _repository.updateTask(task);
  }
}

/// Mục đích: UseCase: Update task.
/// Vị trí: lib/domain/usecases/update_task.dart

// TODO: Implement UpdateTask usecase
