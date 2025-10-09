/// UseCase cho việc xóa project
/// Vị trí: lib/domain/usecases/delete_project.dart

import '../../repositories/project_repository.dart';

class DeleteProject {
  final ProjectRepository _projectRepository;

  DeleteProject(this._projectRepository);

  Future<void> execute(String projectId) async {
    return await _projectRepository.deleteProject(projectId);
  }
}