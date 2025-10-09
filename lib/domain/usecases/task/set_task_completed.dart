import '../../repositories/task_repository.dart';
import '../../entities/task.dart';

class SetTaskCompleted {
  final TaskRepository _repository;

  SetTaskCompleted(this._repository);

  Future<Task> execute(
    String projectId,
    String taskId,
    bool isCompleted,
  ) async {
    return await _repository.setTaskCompleted(projectId, taskId, isCompleted);
  }
}
