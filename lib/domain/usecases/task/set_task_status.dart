import '../../repositories/task_repository.dart';
import '../../entities/task.dart';

class SetTaskStatus {
  final TaskRepository _repository;

  SetTaskStatus(this._repository);

  Future<void> execute({
    required String projectId,
    required String taskId,
    required TaskStatus status,
  }) async {
    await _repository.updateTaskStatus(
      projectId: projectId,
      taskId: taskId,
      status: status,
    );
  }
}
