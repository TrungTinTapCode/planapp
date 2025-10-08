/// Implementation của ProjectRepository với Firebase
/// Vị trí: lib/data/repositories_impl/project_repository_impl.dart

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/firebase/project_service.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectService _projectService;

  ProjectRepositoryImpl(this._projectService);

  @override
  Future<ProjectEntity> createProject(ProjectEntity project) async {
    try {
      final projectModel = ProjectModel.fromEntity(project);
      await _projectService.createProject(projectModel);
      return project;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  @override
  Stream<List<ProjectEntity>> getProjectsByUser(String userId) {
    return _projectService
        .getProjectsByUser(userId)
        .map(
          (projectModels) =>
              projectModels.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<ProjectEntity?> getProjectById(String projectId) async {
    try {
      final projectModel = await _projectService.getProjectById(projectId);
      return projectModel?.toEntity();
    } catch (e) {
      throw Exception('Failed to get project: $e');
    }
  }

  @override
  Future<void> updateProject(ProjectEntity project) async {
    try {
      final projectModel = ProjectModel.fromEntity(project);
      await _projectService.updateProject(projectModel);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  @override
  Future<void> addMemberToProject(String projectId, String memberId) async {
    try {
      await _projectService.addMember(projectId, memberId);
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  @override
  Future<void> removeMemberFromProject(
    String projectId,
    String memberId,
  ) async {
    try {
      await _projectService.removeMember(projectId, memberId);
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }
}
