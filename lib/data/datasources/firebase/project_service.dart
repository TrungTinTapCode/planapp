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

  /// Lấy danh sách user models của các member trong project
  Future<List<Map<String, dynamic>>> getMembers(String projectId) async {
    print('🔍 ProjectService.getMembers: projectId=$projectId');

    final doc = await _firestore.collection('projects').doc(projectId).get();
    if (!doc.exists) {
      print('❌ Project document does not exist');
      return [];
    }

    final data = doc.data()!;
    print('📄 Project data: ${data.keys.toList()}');

    final List<dynamic> memberIds = data['memberIds'] ?? [];
    print('👥 MemberIds in project: $memberIds (count: ${memberIds.length})');

    if (memberIds.isEmpty) {
      print('⚠️ Project has no memberIds array or it is empty');
      return [];
    }

    final users = <Map<String, dynamic>>[];
    for (final id in memberIds) {
      print('  🔍 Fetching user: $id');
      final udoc = await _firestore.collection('users').doc(id as String).get();
      if (udoc.exists) {
        final udata = udoc.data()!;
        users.add({...udata, 'id': udoc.id});
        print('  ✅ Found user: ${udata['displayName'] ?? udata['email']}');
      } else {
        print('  ❌ User document not found: $id');
      }
    }

    print('✅ Total users loaded: ${users.length}');
    return users;
  }

  /// Tìm user id theo email trong collection 'users'. Trả về null nếu không tìm thấy.
  Future<String?> getUserIdByEmail(String email) async {
    final query =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  Stream<List<Map<String, dynamic>>> getMemberStream(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (!snapshot.exists) return [];
          final data = snapshot.data()!;
          final List<dynamic> memberIds = data['memberIds'] ?? [];
          final users = <Map<String, dynamic>>[];
          for (final id in memberIds) {
            final udoc =
                await _firestore.collection('users').doc(id as String).get();
            if (udoc.exists) {
              final udata = udoc.data()!;
              users.add({...udata, 'id': udoc.id});
            }
          }
          return users;
        });
  }
}
