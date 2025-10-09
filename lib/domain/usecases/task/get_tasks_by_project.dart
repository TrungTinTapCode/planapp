import '../../repositories/task_repository.dart';
import '../../entities/task.dart';

class GetTasksByProject {
  final TaskRepository _repository;

  GetTasksByProject(this._repository);

  Future<List<Task>> execute(String projectId) async {
    return await _repository.getTasksByProject(projectId);
  }
}
