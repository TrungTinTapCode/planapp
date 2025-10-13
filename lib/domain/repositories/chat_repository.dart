import '../entities/message.dart';

abstract class ChatRepository {
  Stream<List<MessageEntity>> getMessages(String projectId);
  Future<void> sendMessage(MessageEntity message);
  Future<void> markMessageSeen(
    String projectId,
    String messageId,
    String userId,
  );
}

/// Mục đích: Interface ChatRepository (abstract) cho domain.
/// Vị trí: lib/domain/repositories/chat_repository.dart

// TODO: Định nghĩa abstract class ChatRepository
