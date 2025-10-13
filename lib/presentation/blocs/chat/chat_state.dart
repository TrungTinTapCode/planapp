import '../../../domain/entities/message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoadSuccess extends ChatState {
  final List<MessageEntity> messages;
  ChatLoadSuccess(this.messages);
}

class ChatOperationFailure extends ChatState {
  final String message;
  ChatOperationFailure(this.message);
}

/// Mục đích: Định nghĩa các ChatState.
/// Vị trí: lib/presentation/blocs/chat/chat_state.dart

// TODO: Add Chat states
