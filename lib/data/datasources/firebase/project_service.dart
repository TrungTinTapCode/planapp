/// ProjectService: wrapper around Firestore for project operations
/// Vị trí: lib/data/datasources/firebase/project_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore;

  ProjectService(this._firestore);

  Future<void> createProject(ProjectModel model) async {
    final docRef = _firestore.collection('projects').doc(model.id);
    await docRef.set(model.toMap());
  }

  Stream<List<ProjectModel>> getProjectsByUser(String userId) {
    return _firestore
        .collection('projects')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((d) => ProjectModel.fromMap(d.data(), d.id))
                  .toList(),
        );
  }

  Future<ProjectModel?> getProjectById(String projectId) async {
    final doc = await _firestore.collection('projects').doc(projectId).get();
    if (!doc.exists) return null;
    return ProjectModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateProject(ProjectModel model) async {
    await _firestore.collection('projects').doc(model.id).update(model.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _firestore.collection('projects').doc(projectId).delete();
  }

  Future<void> addMember(String projectId, String memberId) async {
    await _firestore.collection('projects').doc(projectId).update({
      'memberIds': FieldValue.arrayUnion([memberId]),
    });
  }

  Future<void> removeMember(String projectId, String memberId) async {
    await _firestore.collection('projects').doc(projectId).update({
      'memberIds': FieldValue.arrayRemove([memberId]),
    });
  }
}
