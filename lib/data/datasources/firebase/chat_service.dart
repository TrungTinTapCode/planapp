/// Mục đích: Service tương tác với Firebase cho Chat.
/// Vị trí: lib/data/datasources/firebase/chat_service.dart

// TODO: Thêm các method gửi/nhận tin nhắn
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore;

  ChatService(this._firestore);

  /// Stream các message cho project (sắp xếp theo timestamp tăng dần)
  Stream<List<MessageModel>> getMessages(String projectId) {
    final col = _firestore
        .collection('projects')
        .doc(projectId)
        .collection('messages');
    return col.orderBy('timestamp', descending: false).snapshots().map((snap) {
      return snap.docs
          .map((d) => MessageModel.fromJson(d.data(), d.id))
          .toList();
    });
  }

  /// Gửi một message (thêm doc mới vào collection)
  Future<void> sendMessage(MessageModel message) async {
    final col = _firestore
        .collection('projects')
        .doc(message.projectId)
        .collection('messages');
    final docRef = col.doc(message.id);
    await docRef.set(message.toJson());
  }
}
