/// Abstract repository cho Project operations
/// Vị trí: lib/domain/repositories/project_repository.dart

import '../entities/project.dart';

abstract class ProjectRepository {
  // Tạo project mới
  Future<ProjectEntity> createProject(ProjectEntity project);
  
  // Lấy danh sách projects của user
  Stream<List<ProjectEntity>> getProjectsByUser(String userId);
  
  // Lấy project theo ID
  Future<ProjectEntity?> getProjectById(String projectId);
  
  // Cập nhật project
  Future<void> updateProject(ProjectEntity project);
  
  // Xóa project
  Future<void> deleteProject(String projectId);
  
  // Thêm member vào project
  Future<void> addMemberToProject(String projectId, String memberId);
  
  // Xóa member khỏi project
  Future<void> removeMemberFromProject(String projectId, String memberId);
}