import '../../repositories/task_repository.dart';
import '../../entities/task.dart';
import '../../entities/user.dart';

class AssignTask {
  final TaskRepository _repository;

  AssignTask(this._repository);

  Future<Task> execute(String projectId, String taskId, User? assignee) async {
    return await _repository.assignTask(projectId, taskId, assignee);
  }
}
