/// UseCase cho việc lấy danh sách projects của user
/// Vị trí: lib/domain/usecases/get_projects.dart

import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjects {
  final ProjectRepository _projectRepository;

  GetProjects(this._projectRepository);

  Stream<List<ProjectEntity>> execute(String userId) {
    return _projectRepository.getProjectsByUser(userId);
  }
}