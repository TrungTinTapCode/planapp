/// Mục đích: Service tương tác với Firebase cho Task.
/// Vị trí: lib/data/datasources/firebase/task_service.dart

// TODO: Thêm các method fetch/create/update task
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore;

  TaskService(this._firestore);

  Future<void> createTask(TaskModel task) async {
    await _firestore
        .collection('projects')
        .doc(task.projectId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }

  Future<void> updateTask(TaskModel task) async {
    await _firestore
        .collection('projects')
        .doc(task.projectId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toJson());
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<TaskModel?> getTaskById(String projectId, String taskId) async {
    final doc =
        await _firestore
            .collection('projects')
            .doc(projectId)
            .collection('tasks')
            .doc(taskId)
            .get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return TaskModel.fromJson({...data, 'id': doc.id, 'projectId': projectId});
  }

  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    final snapshot =
        await _firestore
            .collection('projects')
            .doc(projectId)
            .collection('tasks')
            .get();
    return snapshot.docs
        .map(
          (d) => TaskModel.fromJson({
            ...d.data(),
            'id': d.id,
            'projectId': projectId,
          }),
        )
        .toList();
  }

  Stream<QuerySnapshot> getTaskStream(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .snapshots();
  }
}
