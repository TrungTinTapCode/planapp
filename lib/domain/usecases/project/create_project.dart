/// UseCase cho việc tạo project mới
/// Vị trí: lib/domain/usecases/create_project.dart

import '../../entities/project.dart';
import '../../repositories/project_repository.dart';

class CreateProject {
  final ProjectRepository _projectRepository;

  CreateProject(this._projectRepository);

  Future<ProjectEntity> execute({
    required String name,
    required String description,
    required String ownerId,
  }) async {
    final project = ProjectEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      ownerId: ownerId,
      memberIds: [ownerId], // Thêm owner làm member đầu tiên
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return await _projectRepository.createProject(project);
  }
}