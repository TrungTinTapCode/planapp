/// Events cho Project Bloc
/// Vị trí: lib/presentation/blocs/project/project_event.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event lấy danh sách projects
class ProjectLoadRequested extends ProjectEvent {
  final String userId;

  ProjectLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Event tạo project mới
class ProjectCreateRequested extends ProjectEvent {
  final String name;
  final String description;
  final String ownerId;

  ProjectCreateRequested({
    required this.name,
    required this.description,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [name, description, ownerId];
}

// Event cập nhật project
class ProjectUpdateRequested extends ProjectEvent {
  final ProjectEntity project;

  ProjectUpdateRequested(this.project);

  @override
  List<Object?> get props => [project];
}

// Event xóa project
class ProjectDeleteRequested extends ProjectEvent {
  final String projectId;

  ProjectDeleteRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// Event thêm member vào project
class ProjectAddMemberRequested extends ProjectEvent {
  final String projectId;
  final String memberId;

  ProjectAddMemberRequested({
    required this.projectId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [projectId, memberId];
}