/// Mục đích: Triển khai ChatRepository.
/// Vị trí: lib/data/repositories_impl/chat_repository_impl.dart
import '../datasources/firebase/chat_service.dart';
import '../models/message_model.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _chatService;

  ChatRepositoryImpl(this._chatService);

  @override
  Stream<List<MessageEntity>> getMessages(String projectId) {
    return _chatService
        .getMessages(projectId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> sendMessage(MessageEntity message) async {
    final model = MessageModel.fromEntity(message);
    await _chatService.sendMessage(model);
  }

  @override
  Future<void> markMessageSeen(
    String projectId,
    String messageId,
    String userId,
  ) async {
    await _chatService.markMessageSeen(projectId, messageId, userId);
  }
}
