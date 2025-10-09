/// UseCase cho việc thêm member vào project
/// Vị trí: lib/domain/usecases/add_member_to_project.dart

import '../../repositories/project_repository.dart';

class AddMemberToProject {
  final ProjectRepository _projectRepository;

  AddMemberToProject(this._projectRepository);

  Future<void> execute(String projectId, String memberId) async {
    return await _projectRepository.addMemberToProject(projectId, memberId);
  }
}