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

    // Nếu task có assignee ngay khi tạo -> tạo thông báo cho người được gán
    if (task.assignee != null) {
      await createTaskAssignedNotification(task.assignee!.id, task);
    }
  }

  Future<void> updateTask(TaskModel task) async {
    await _firestore
        .collection('projects')
        .doc(task.projectId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toJson());
  }

  Future<void> updateTaskStatus({
    required String projectId,
    required String taskId,
    required String status,
    required bool isCompleted,
  }) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .update({'status': status, 'isCompleted': isCompleted});
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

  /// Stream tất cả task (ở mọi project) được gán cho một user
  Stream<List<TaskModel>> streamTasksAssignedToUser(String userId) {
    return _firestore
        .collectionGroup('tasks')
        .where('assignee.id', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) {
                final data = d.data();
                // Lấy projectId từ path: projects/{projectId}/tasks/{taskId}
                final projectId = d.reference.parent.parent?.id;
                return TaskModel.fromJson({
                  ...data,
                  'id': d.id,
                  if (projectId != null) 'projectId': projectId,
                });
              }).toList(),
        );
  }

  /// Tạo thông báo cho user khi được gán vào một task
  Future<void> createTaskAssignedNotification(
    String userId,
    TaskModel task, {
    String? assignerId,
    String? assignerName,
    String? projectName,
  }) async {
    final notifRef =
        _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc();
    await notifRef.set({
      'title': 'Bạn được giao nhiệm vụ mới',
      'body':
          assignerName != null && projectName != null
              ? '$assignerName đã giao task cho bạn trong $projectName'
              : 'Công việc: ${task.title}',
      'type': 'TASK_ASSIGNED',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'projectId': task.projectId,
      'taskId': task.id,
      if (assignerId != null) 'assignerId': assignerId,
      if (assignerName != null) 'assignerName': assignerName,
    });
  }

  Future<void> addTaskComment({
    required String projectId,
    required String taskId,
    required Map<String, dynamic> comment,
  }) async {
    final commentsRef =
        _firestore
            .collection('projects')
            .doc(projectId)
            .collection('tasks')
            .doc(taskId)
            .collection('comments')
            .doc();
    await commentsRef.set({
      ...comment,
      'id': commentsRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamTaskComments({
    required String projectId,
    required String taskId,
  }) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('comments')
        // Hiển thị bình luận theo thời gian tăng dần để comment mới nằm dưới
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> createCommentNotification({
    required String notifyUserId,
    required String projectId,
    required String taskId,
    required String taskTitle,
    required String commenterId,
    required String commenterName,
  }) async {
    final notifRef =
        _firestore
            .collection('users')
            .doc(notifyUserId)
            .collection('notifications')
            .doc();
    await notifRef.set({
      'title': 'Bình luận mới',
      'body': '$commenterName đã bình luận về "$taskTitle"',
      'type': 'TASK_COMMENTED',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'projectId': projectId,
      'taskId': taskId,
      'commenterId': commenterId,
      'commenterName': commenterName,
    });
  }
}
