/// UseCase cho việc cập nhật project
/// Vị trí: lib/domain/usecases/update_project.dart

import '../../entities/project.dart';
import '../../repositories/project_repository.dart';

class UpdateProject {
  final ProjectRepository _projectRepository;

  UpdateProject(this._projectRepository);

  Future<void> execute(ProjectEntity project) async {
    final updatedProject = ProjectEntity(
      id: project.id,
      name: project.name,
      description: project.description,
      ownerId: project.ownerId,
      memberIds: project.memberIds,
      createdAt: project.createdAt,
      updatedAt: DateTime.now(), // Cập nhật thời gian
    );
    
    return await _projectRepository.updateProject(updatedProject);
  }
}