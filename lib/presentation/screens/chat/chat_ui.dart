import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../widgets/message_bubble_widget.dart';
import '../../../domain/entities/message.dart';
import '../../../core/di/injection.dart';
import '../../../domain/usecases/user/get_current_user.dart';

class ChatScreenUI extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ChatScreenUI({
    Key? key,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  State<ChatScreenUI> createState() => _ChatScreenUIState();
}

class _ChatScreenUIState extends State<ChatScreenUI> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Request load
    context.read<ChatBloc>().add(
      ChatLoadRequested(projectId: widget.projectId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.projectName)),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is ChatLoadSuccess) {
                  final messages = state.messages;
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      // Determine whether message is from current user
                      final currentUser = sl<GetCurrentUser>().execute();
                      final isMe = currentUser?.id == m.senderId;
                      return MessageBubbleWidget(message: m, isMe: isMe);
                    },
                  );
                }
                if (state is ChatOperationFailure)
                  return Center(child: Text('Error: ${state.message}'));
                return const SizedBox.shrink();
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    final currentUser = sl<GetCurrentUser>().execute();
                    if (currentUser == null) return;
                    final id = DateTime.now().millisecondsSinceEpoch.toString();
                    final message = MessageEntity(
                      id: id,
                      projectId: widget.projectId,
                      senderId: currentUser.id,
                      senderName: currentUser.displayName,
                      content: text,
                      timestamp: DateTime.now(),
                    );
                    context.read<ChatBloc>().add(ChatSendRequested(message));
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
