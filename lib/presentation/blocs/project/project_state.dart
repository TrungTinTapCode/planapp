/// States cho Project Bloc
/// Vị trí: lib/presentation/blocs/project/project_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';

abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoadSuccess extends ProjectState {
  final List<ProjectEntity> projects;

  ProjectLoadSuccess(this.projects);

  @override
  List<Object?> get props => [projects];
}

class ProjectOperationSuccess extends ProjectState {}

class ProjectError extends ProjectState {
  final String message;

  ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}