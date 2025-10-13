import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _sub;

  ChatBloc({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(ChatInitial()) {
    on<ChatLoadRequested>(_onLoadRequested);
    on<ChatMessagesUpdated>(_onMessagesUpdated);
    on<ChatSendRequested>(_onSendRequested);
  }

  Future<void> _onLoadRequested(
    ChatLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await _sub?.cancel();
    _sub = _chatRepository
        .getMessages(event.projectId)
        .listen(
          (messages) {
            add(ChatMessagesUpdated(messages));
          },
          onError: (e) {
            addError(e);
          },
        );
  }

  void _onMessagesUpdated(ChatMessagesUpdated event, Emitter<ChatState> emit) {
    emit(ChatLoadSuccess(event.messages));
  }

  Future<void> _onSendRequested(
    ChatSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.sendMessage(event.message);
    } catch (e) {
      emit(ChatOperationFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

/// Mục đích: Bloc cho Chat.
/// Vị trí: lib/presentation/blocs/chat/chat_bloc.dart

// TODO: Implement ChatBloc
