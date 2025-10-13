// Màn hình chi tiết project - logic và state management
// Vị trí: lib/presentation/screens/project/project_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project.dart';
import '../../blocs/project/project_bloc.dart';
import '../../blocs/project/project_event.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'project_detail_ui.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../../data/datasources/firebase/project_service.dart';
import '../../../core/di/injection.dart';
import '../task/create_task_screen.dart';
import '../task/task_list_screen.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../chat/chat_ui.dart';

class ProjectDetailScreen extends StatelessWidget {
  final ProjectEntity project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ProjectBloc>(context),
      child: _ProjectDetailScreenContent(project: project),
    );
  }
}

class _ProjectDetailScreenContent extends StatefulWidget {
  final ProjectEntity project;

  const _ProjectDetailScreenContent({required this.project});

  @override
  State<_ProjectDetailScreenContent> createState() =>
      _ProjectDetailScreenContentState();
}

class _ProjectDetailScreenContentState
    extends State<_ProjectDetailScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _memberProfiles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load tasks for this project when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the TaskBloc to load tasks scoped to this project
      try {
        final taskBloc = context.read<TaskBloc>();
        taskBloc.add(LoadTasksRequested(widget.project.id));
      } catch (_) {
        // If TaskBloc is not provided above in the tree, ignore silently.
      }
      // Also load member profiles
      _loadMemberProfiles();
    });
  }

  Future<void> _loadMemberProfiles() async {
    try {
      final projectService = sl<ProjectService>();
      final users = await projectService.getMembers(widget.project.id);
      setState(() {
        _memberProfiles = users;
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProjectDetailUI.appBar(
        project: widget.project,
        onAddMember: () => _handleAddMember(context),
        onDelete: _isCurrentUserOwner() ? () => _handleDelete(context) : null,
      ),
      body: _buildProjectDetailContent(),
    );
  }

  // Xây dựng nội dung chi tiết project
  Widget _buildProjectDetailContent() {
    return Column(
      children: [
        ProjectDetailUI.projectInfo(project: widget.project),
        const SizedBox(height: 8),
        ProjectDetailUI.tabBar(controller: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTasksTab(),
              _buildMembersTab(),
              _buildFilesTab(),
              _buildChatTab(),
            ],
          ),
        ),
      ],
    );
  }

  // Tab công việc
  Widget _buildTasksTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectDetailUI.sectionHeader(
            title: 'Công việc',
            buttonText: 'Thêm task',
            onPressed: () => _handleAddTask(context),
          ),
          const SizedBox(height: 16),
          Expanded(
            // Show the real Task list for this project
            child: TaskListScreen(projectId: widget.project.id),
          ),
        ],
      ),
    );
  }

  // Tab thành viên
  Widget _buildMembersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectDetailUI.sectionHeader(
            title: 'Thành viên',
            buttonText: 'Thêm thành viên',
            onPressed: () => _handleAddMember(context),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                _memberProfiles.isNotEmpty
                    ? ProjectDetailUI.membersListFromProfiles(
                      profiles: _memberProfiles,
                      currentUserId: _getCurrentUserId(),
                      isOwner: _isCurrentUserOwner(),
                      onRemoveMember:
                          (memberId) => _handleRemoveMember(context, memberId),
                    )
                    : ProjectDetailUI.membersList(
                      members: widget.project.memberIds,
                      currentUserId: _getCurrentUserId(),
                      isOwner: _isCurrentUserOwner(),
                      onRemoveMember:
                          (memberId) => _handleRemoveMember(context, memberId),
                    ),
          ),
        ],
      ),
    );
  }

  // Tab files
  Widget _buildFilesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectDetailUI.sectionHeader(
            title: 'Tệp tin',
            buttonText: 'Thêm file',
            onPressed: () => _handleAddFile(context),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ProjectDetailUI.emptyFilesState(
              onAddFile: () => _handleAddFile(context),
            ),
          ),
        ],
      ),
    );
  }

  // Tab chat/messages
  Widget _buildChatTab() {
    return BlocProvider<ChatBloc>(
      create:
          (context) =>
              sl<ChatBloc>()
                ..add(ChatLoadRequested(projectId: widget.project.id)),
      child: ChatScreenUI(
        projectId: widget.project.id,
        projectName: widget.project.name,
      ),
    );
  }

  // Xử lý thêm thành viên
  void _handleAddMember(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectDetailUI.addMemberDialog(
            context: context,
            onAddMember: (email) => _addMemberByEmail(context, email),
          ),
    );
  }

  // Thêm thành viên bằng email
  void _addMemberByEmail(BuildContext context, String email) {
    // Thực hiện tìm user theo email trong collection 'users'
    final projectService = sl<ProjectService>();
    projectService
        .getUserIdByEmail(email)
        .then((userId) {
          if (userId == null) {
            Navigator.pop(context);
            _showErrorSnackbar(
              context,
              'Không tìm thấy người dùng với email đó',
            );
            return;
          }

          context.read<ProjectBloc>().add(
            ProjectAddMemberRequested(
              projectId: widget.project.id,
              memberId: userId,
            ),
          );

          Navigator.pop(context);
          _showSuccessSnackbar(context, 'Đã thêm thành viên vào dự án');
        })
        .catchError((e) {
          Navigator.pop(context);
          _showErrorSnackbar(context, 'Lỗi khi tìm người dùng: $e');
        });
  }

  // Xử lý xóa thành viên
  void _handleRemoveMember(BuildContext context, String memberId) {
    if (memberId == widget.project.ownerId) {
      _showErrorSnackbar(context, 'Không thể xóa chủ sở hữu dự án');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => ProjectDetailUI.removeMemberDialog(
            context: context,
            onConfirm: () {
              // TODO: Implement remove member logic
              Navigator.pop(context);
              _showSuccessSnackbar(context, 'Đã xóa thành viên khỏi dự án');
            },
          ),
    );
  }

  // Xử lý thêm task
  void _handleAddTask(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CreateTaskScreen(projectId: widget.project.id),
          ),
        )
        .then((created) {
          if (created == true) {
            // Rebuild to recreate TaskListScreen which will reload tasks
            setState(() {});
            _showSuccessSnackbar(context, 'Tạo task thành công');
          }
        });
  }

  // Xử lý thêm file
  void _handleAddFile(BuildContext context) {
    // TODO: Implement file upload logic
    _showInfoSnackbar(
      context,
      'Tính năng upload file sẽ có trong phiên bản tiếp theo',
    );
  }

  // Lấy current user ID
  String _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return '';
  }

  // Kiểm tra current user có phải là owner không
  bool _isCurrentUserOwner() {
    return _getCurrentUserId() == widget.project.ownerId;
  }

  // Hiển thị thông báo thành công
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Hiển thị thông báo lỗi
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Hiển thị thông báo thông tin
  void _showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }

  // Xử lý xóa project
  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa dự án'),
            content: const Text(
              'Bạn có chắc muốn xóa dự án này? Hành động không thể hoàn tác.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Gửi event xóa project cho bloc
                  context.read<ProjectBloc>().add(
                    ProjectDeleteRequested(widget.project.id),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context); // thoát màn hình chi tiết
                  _showSuccessSnackbar(context, 'Đã xóa dự án');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }
}
