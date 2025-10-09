import '../../repositories/task_repository.dart';
import '../../entities/task.dart';

class GetTaskById {
  final TaskRepository _repository;

  GetTaskById(this._repository);

  Future<Task?> execute(String projectId, String taskId) async {
    return await _repository.getTaskById(projectId, taskId);
  }
}
