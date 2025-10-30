// Màn hình danh sách projects - logic và state management
// Vị trí: lib/presentation/screens/project/project_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project.dart';
import '../../blocs/project/project_bloc.dart';
import '../../blocs/project/project_event.dart';
import '../../blocs/project/project_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';
import 'project_list_ui.dart';

class ProjectListScreen extends StatelessWidget {
  final bool embedded; // ✅ Cho phép nhúng vào TabBarView
  const ProjectListScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return _ProjectListScreenContent(embedded: embedded);
  }
}

class _ProjectListScreenContent extends StatefulWidget {
  final bool embedded;
  const _ProjectListScreenContent({this.embedded = false});

  @override
  State<_ProjectListScreenContent> createState() =>
      _ProjectListScreenContentState();
}

class _ProjectListScreenContentState extends State<_ProjectListScreenContent> {
  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  // Load projects khi screen khởi tạo
  void _loadProjects() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProjectBloc>().add(ProjectLoadRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Stack(
        children: [
          _buildProjectList(),
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildFloatingActionButton(),
          ),
        ],
      );
    }
    return Scaffold(
      appBar: ProjectListUI.appBar(),
      body: _buildProjectList(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Xây dựng danh sách projects
  Widget _buildProjectList() {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        // Có thể thêm các xử lý khi state thay đổi ở đây
      },
      builder: (context, state) {
        if (state is ProjectLoading) {
          return ProjectListUI.loadingState();
        }

        if (state is ProjectError) {
          return ProjectListUI.errorState(
            message: state.message,
            onRetry: _loadProjects,
          );
        }

        if (state is ProjectLoadSuccess) {
          final projects = state.projects;

          if (projects.isEmpty) {
            return ProjectListUI.emptyState(
              onCreateProject: _navigateToCreateProject,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadProjects(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ProjectListUI.projectCard(
                  project: projects[index],
                  onTap: () => _navigateToProjectDetail(projects[index]),
                );
              },
            ),
          );
        }

        return ProjectListUI.emptyState(
          onCreateProject: _navigateToCreateProject,
        );
      },
    );
  }

  // Nút tạo project mới
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToCreateProject,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  // Điều hướng đến màn hình tạo project
  void _navigateToCreateProject() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    ).then((result) {
      if (result is ProjectEntity) {
        // Hiển thị thông báo thành công rồi điều hướng tới màn chi tiết
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo dự án thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          _navigateToProjectDetail(result);
        });
      } else {
        // Nếu không có result (đóng màn hình), refresh danh sách
        _loadProjects();
      }
    });
  }

  // Điều hướng đến màn hình chi tiết project
  void _navigateToProjectDetail(ProjectEntity project) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
    );
  }
}
