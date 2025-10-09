/// Mục đích: Triển khai TaskRepository.
/// Vị trí: lib/data/repositories_impl/task_repository_impl.dart

import '../../domain/entities/task.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firebase/task_service.dart';
import '../models/task_model.dart';

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
      return model;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByProject(String projectId) async {
    try {
      final models = await _taskService.getTasksByProject(projectId);
      return models.map((m) => m as Task).toList();
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
      final updatedTask = model.copyWith(assignee: assignee);
      final updatedModel = TaskModel.fromTask(updatedTask);
      await _taskService.updateTask(updatedModel);
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
      final updatedTask = model.copyWith(isCompleted: isCompleted);
      final updatedModel = TaskModel.fromTask(updatedTask);
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
}
