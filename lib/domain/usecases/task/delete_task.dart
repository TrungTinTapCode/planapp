import '../../repositories/task_repository.dart';

class DeleteTask {
  final TaskRepository _repository;

  DeleteTask(this._repository);

  Future<void> execute(String projectId, String taskId) async {
    return await _repository.deleteTask(projectId, taskId);
  }
}
