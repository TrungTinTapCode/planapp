/// Mục đích: Triển khai TaskRepository.
/// Vị trí: lib/data/repositories_impl/task_repository_impl.dart

import '../../domain/entities/task.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firebase/task_service.dart';
import '../models/task_model.dart';
import '../models/task_comment_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskService _taskService;

  TaskRepositoryImpl(this._taskService);

  @override
  Future<Task> createTask(Task task) async {
    try {
      final model = TaskModel.fromTask(task);
      await _taskService.createTask(model);
      return task;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  Future<void> deleteTask(String projectId, String taskId) async {
    try {
      await _taskService.deleteTask(projectId, taskId);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Future<Task?> getTaskById(String projectId, String taskId) async {
    try {
      final model = await _taskService.getTaskById(projectId, taskId);
      return model; // ✅ Vì TaskModel extends Task, nên có thể return trực tiếp
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByProject(String projectId) async {
    try {
      final models = await _taskService.getTasksByProject(projectId);
      return models; // ✅ Vì List<TaskModel> là List<Task> (do inheritance)
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  Future<Task> assignTask(
    String projectId,
    String taskId,
    User? assignee,
  ) async {
    try {
      final model = await _taskService.getTaskById(projectId, taskId);
      if (model == null) throw Exception('Task not found');

      // ✅ Tạo TaskModel mới với assignee updated
      final updatedModel = TaskModel(
        id: model.id,
        projectId: model.projectId,
        title: model.title,
        description: model.description,
        deadline: model.deadline,
        tags: model.tags,
        priority: model.priority,
        assignee: assignee, // ✅ Cập nhật assignee
        createdAt: model.createdAt,
        creator: model.creator,
        isCompleted: model.isCompleted,
      );

      await _taskService.updateTask(updatedModel);

      // Nếu có assignee mới, tạo thông báo cho người đó
      if (assignee != null && assignee.id != model.assignee?.id) {
        await _taskService.createTaskAssignedNotification(
          assignee.id,
          updatedModel,
          assignerId: updatedModel.creator.id,
          assignerName: _displayNameOrEmail(updatedModel.creator),
          projectName: updatedModel.projectId,
        );
      }
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to assign task: $e');
    }
  }

  @override
  Future<Task> setTaskCompleted(
    String projectId,
    String taskId,
    bool isCompleted,
  ) async {
    try {
      final model = await _taskService.getTaskById(projectId, taskId);
      if (model == null) throw Exception('Task not found');

      // ✅ Tạo TaskModel mới với isCompleted updated
      final updatedModel = TaskModel(
        id: model.id,
        projectId: model.projectId,
        title: model.title,
        description: model.description,
        deadline: model.deadline,
        tags: model.tags,
        priority: model.priority,
        assignee: model.assignee,
        createdAt: model.createdAt,
        creator: model.creator,
        isCompleted: isCompleted, // ✅ Cập nhật isCompleted
      );

      await _taskService.updateTask(updatedModel);
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to set completed: $e');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      final model = TaskModel.fromTask(task);
      await _taskService.updateTask(model);
      return task;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Stream<List<Task>> getTaskStreamByProject(String projectId) {
    return _taskService.getTaskStream(projectId).map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<Task>> streamTasksAssignedToUser(String userId) {
    return _taskService
        .streamTasksAssignedToUser(userId)
        .map((models) => models);
  }

  @override
  Future<void> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus status,
  }) async {
    try {
      await _taskService.updateTaskStatus(
        projectId: projectId,
        taskId: taskId,
        status: status.name,
        isCompleted: status == TaskStatus.done,
      );
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  Future<void> addComment({
    required String projectId,
    required String taskId,
    required TaskCommentModel comment,
    String? notifyUserId,
    String? taskTitle,
  }) async {
    await _taskService.addTaskComment(
      projectId: projectId,
      taskId: taskId,
      comment: comment.toJson(),
    );
    if (notifyUserId != null && taskTitle != null) {
      await _taskService.createCommentNotification(
        notifyUserId: notifyUserId,
        projectId: projectId,
        taskId: taskId,
        taskTitle: taskTitle,
        commenterId: comment.author.id,
        commenterName: _displayNameOrEmail(comment.author),
      );
    }
  }
}

String _displayNameOrEmail(User user) {
  // User entity likely has non-nullable displayName/email types; map to a safe string
  final name = (user.displayName).toString();
  if (name.isNotEmpty) return name;
  final email = (user.email).toString();
  return email.isNotEmpty ? email : 'Ai đó';
}
