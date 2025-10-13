import '../entities/message.dart';

abstract class ChatRepository {
  Stream<List<MessageEntity>> getMessages(String projectId);
  Future<void> sendMessage(MessageEntity message);
}

/// Mục đích: Interface ChatRepository (abstract) cho domain.
/// Vị trí: lib/domain/repositories/chat_repository.dart

// TODO: Định nghĩa abstract class ChatRepository
