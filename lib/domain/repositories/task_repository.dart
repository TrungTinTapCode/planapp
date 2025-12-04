/// Mục đích: Interface TaskRepository (abstract) cho domain.
/// Vị trí: lib/domain/repositories/task_repository.dart
import 'package:planapp/domain/entities/task.dart';
import 'package:planapp/domain/entities/user.dart';

/// Interface repository cho Task (domain layer)
abstract class TaskRepository {
  /// Tạo task mới
  Future<Task> createTask(Task task);

  /// Cập nhật task (bao gồm thay đổi assignee, tags, priority, deadline,...)
  Future<Task> updateTask(Task task);

  /// Xóa task theo projectId và taskId
  Future<void> deleteTask(String projectId, String taskId);

  /// Lấy danh sách task theo projectId
  Future<List<Task>> getTasksByProject(String projectId);

  /// Gán task cho một user (userId có thể là null để unassign)
  Future<Task> assignTask(String projectId, String taskId, User? assignee);

  /// Đánh dấu hoàn thành
  Future<Task> setTaskCompleted(
    String projectId,
    String taskId,
    bool isCompleted,
  );

  /// Tìm task theo id
  Future<Task?> getTaskById(String projectId, String taskId);

  /// Lắng nghe thay đổi danh sách task theo projectId
  Stream<List<Task>> getTaskStreamByProject(String projectId);

  /// Lắng nghe tất cả task được gán cho một user (collection group 'tasks')
  Stream<List<Task>> streamTasksAssignedToUser(String userId);

  /// Cập nhật trạng thái (status) của task: todo/inProgress/done
  /// Đồng thời cập nhật isCompleted = (status == TaskStatus.done) để tương thích dữ liệu cũ.
  Future<void> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus status,
  });
}
