import '../../../domain/entities/message.dart';

abstract class ChatEvent {}

class ChatLoadRequested extends ChatEvent {
  final String projectId;
  ChatLoadRequested({required this.projectId});
}

class ChatMessagesUpdated extends ChatEvent {
  final List<MessageEntity> messages;
  ChatMessagesUpdated(this.messages);
}

class ChatSendRequested extends ChatEvent {
  final MessageEntity message;
  ChatSendRequested(this.message);
}

class ChatMarkSeenRequested extends ChatEvent {
  final String projectId;
  final String messageId;
  final String userId;
  ChatMarkSeenRequested({
    required this.projectId,
    required this.messageId,
    required this.userId,
  });
}

/// Mục đích: Định nghĩa các ChatEvent.
/// Vị trí: lib/presentation/blocs/chat/chat_event.dart

// TODO: Add Chat events
