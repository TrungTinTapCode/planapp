/// UI Components tập trung cho màn hình chi tiết project
/// Vị trí: lib/presentation/screens/project/project_detail_ui.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectDetailUI {
  // AppBar cho màn hình chi tiết project
  static AppBar appBar({
    required ProjectEntity project,
    required VoidCallback onAddMember,
    VoidCallback? onDelete,
  }) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            '${project.memberIds.length} thành viên',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: onAddMember,
          tooltip: 'Thêm thành viên',
        ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            tooltip: 'Xóa dự án',
            color: Colors.redAccent,
          ),
      ],
    );
  }

  // Thông tin project
  static Widget projectInfo({required ProjectEntity project}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          if (project.description.isNotEmpty) ...[
            Text(
              project.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${project.memberIds.length} thành viên',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _formatDate(project.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tab bar
  static Widget tabBar({required TabController controller}) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(icon: Icon(Icons.task), text: 'Công việc'),
          Tab(icon: Icon(Icons.people), text: 'Thành viên'),
          Tab(icon: Icon(Icons.folder), text: 'Tệp tin'),
          Tab(icon: Icon(Icons.chat_bubble), text: 'Tin nhắn'),
        ],
      ),
    );
  }

  // Section header với button
  static Widget sectionHeader({
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add, size: 16),
          label: Text(buttonText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  // Empty state cho tasks
  static Widget emptyTasksState({required VoidCallback onAddTask}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.task, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Chưa có công việc nào',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm công việc đầu tiên để bắt đầu',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddTask,
            icon: const Icon(Icons.add),
            label: const Text('Thêm công việc'),
          ),
        ],
      ),
    );
  }

  // Empty state cho files
  static Widget emptyFilesState({required VoidCallback onAddFile}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Chưa có tệp tin nào',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tải lên tệp tin đầu tiên',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Tải lên tệp tin'),
          ),
        ],
      ),
    );
  }

  // Danh sách thành viên
  static Widget membersList({
    required List<String> members,
    required String currentUserId,
    required bool isOwner,
    required Function(String) onRemoveMember,
  }) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final memberId = members[index];
        final isCurrentUser = memberId == currentUserId;
        final isOwnerMember = memberId == currentUserId && isOwner;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getMemberColor(memberId),
            child: Text(
              _getMemberInitial(memberId),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            _getMemberName(memberId),
            style: TextStyle(
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: isOwnerMember ? const Text('Chủ sở hữu') : null,
          trailing:
              isOwner && !isCurrentUser
                  ? IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => onRemoveMember(memberId),
                    tooltip: 'Xóa thành viên',
                  )
                  : null,
        );
      },
    );
  }

  /// Hiển thị danh sách thành viên từ profile maps trả về từ ProjectService.getMembers
  /// mỗi profile là Map chứa 'id','displayName','photoUrl',...
  static Widget membersListFromProfiles({
    required List<Map<String, dynamic>> profiles,
    required String currentUserId,
    required bool isOwner,
    required Function(String) onRemoveMember,
  }) {
    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final p = profiles[index];
        final memberId = p['id'] as String? ?? '';
        final displayName =
            p['displayName'] as String? ?? p['name'] as String? ?? 'User';
        final photoUrl = p['photoUrl'] as String?;
        final isCurrentUser = memberId == currentUserId;

        return ListTile(
          leading:
              photoUrl != null
                  ? CircleAvatar(backgroundImage: NetworkImage(photoUrl))
                  : CircleAvatar(
                    backgroundColor: _getMemberColor(memberId),
                    child: Text(
                      _getMemberInitial(memberId),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
          title: Text(
            displayName,
            style: TextStyle(
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: isCurrentUser ? const Text('Bạn') : null,
          trailing:
              isOwner && !isCurrentUser
                  ? IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => onRemoveMember(memberId),
                  )
                  : null,
        );
      },
    );
  }

  // Dialog thêm thành viên
  static Widget addMemberDialog({
    required Function(String) onAddMember,
    required BuildContext context,
  }) {
    final emailController = TextEditingController();

    return AlertDialog(
      title: const Text('Thêm thành viên'),
      content: TextField(
        controller: emailController,
        decoration: const InputDecoration(
          labelText: 'Email thành viên',
          hintText: 'Nhập email...',
          prefixIcon: Icon(Icons.email),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final email = emailController.text.trim();
            if (email.isNotEmpty) {
              onAddMember(email);
            }
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }

  // Dialog xóa thành viên
  static Widget removeMemberDialog({
    required VoidCallback onConfirm,
    required BuildContext context,
  }) {
    return AlertDialog(
      title: const Text('Xóa thành viên'),
      content: const Text('Bạn có chắc muốn xóa thành viên này khỏi dự án?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Xóa'),
        ),
      ],
    );
  }

  // Helper functions
  static Color _getMemberColor(String memberId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final index = memberId.hashCode % colors.length;
    return colors[index];
  }

  static String _getMemberInitial(String memberId) {
    return memberId.isNotEmpty ? memberId[0].toUpperCase() : 'U';
  }

  static String _getMemberName(String memberId) {
    return 'User ${memberId.substring(0, 6)}...';
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
