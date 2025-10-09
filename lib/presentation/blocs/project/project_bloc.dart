/// Bloc quản lý state cho Project
/// Vị trí: lib/presentation/blocs/project/project_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/project/create_project.dart';
import '../../../domain/usecases/project/get_projects.dart';
import '../../../domain/usecases/project/update_project.dart';
import '../../../domain/usecases/project/delete_project.dart';
import '../../../domain/usecases/project/add_member_to_project.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final CreateProject _createProject;
  final GetProjects _getProjects;
  final UpdateProject _updateProject;
  final DeleteProject _deleteProject;
  final AddMemberToProject _addMemberToProject;

  ProjectBloc({
    required CreateProject createProject,
    required GetProjects getProjects,
    required UpdateProject updateProject,
    required DeleteProject deleteProject,
    required AddMemberToProject addMemberToProject,
  })  : _createProject = createProject,
        _getProjects = getProjects,
        _updateProject = updateProject,
        _deleteProject = deleteProject,
        _addMemberToProject = addMemberToProject,
        super(ProjectInitial()) {
    on<ProjectLoadRequested>(_onProjectLoadRequested);
    on<ProjectCreateRequested>(_onProjectCreateRequested);
    on<ProjectUpdateRequested>(_onProjectUpdateRequested);
    on<ProjectDeleteRequested>(_onProjectDeleteRequested);
    on<ProjectAddMemberRequested>(_onProjectAddMemberRequested);
  }

  // Xử lý load projects
  Future<void> _onProjectLoadRequested(
    ProjectLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final projectsStream = _getProjects.execute(event.userId);
      await for (final projects in projectsStream) {
        emit(ProjectLoadSuccess(projects));
      }
    } catch (e) {
      emit(ProjectError('Failed to load projects: $e'));
    }
  }

  // Xử lý tạo project
  Future<void> _onProjectCreateRequested(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _createProject.execute(
        name: event.name,
        description: event.description,
        ownerId: event.ownerId,
      );
      // Không emit state mới ở đây vì stream sẽ tự động cập nhật
    } catch (e) {
      emit(ProjectError('Failed to create project: $e'));
    }
  }

  // Xử lý cập nhật project
  Future<void> _onProjectUpdateRequested(
    ProjectUpdateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _updateProject.execute(event.project);
      // Không emit state mới ở đây vì stream sẽ tự động cập nhật
    } catch (e) {
      emit(ProjectError('Failed to update project: $e'));
    }
  }

  // Xử lý xóa project
  Future<void> _onProjectDeleteRequested(
    ProjectDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _deleteProject.execute(event.projectId);
      // Không emit state mới ở đây vì stream sẽ tự động cập nhật
    } catch (e) {
      emit(ProjectError('Failed to delete project: $e'));
    }
  }

  // Xử lý thêm member
  Future<void> _onProjectAddMemberRequested(
    ProjectAddMemberRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _addMemberToProject.execute(event.projectId, event.memberId);
      // Không emit state mới ở đây vì stream sẽ tự động cập nhật
    } catch (e) {
      emit(ProjectError('Failed to add member: $e'));
    }
  }
}