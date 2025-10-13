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

/// Mục đích: Định nghĩa các ChatEvent.
/// Vị trí: lib/presentation/blocs/chat/chat_event.dart

// TODO: Add Chat events
