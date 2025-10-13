/// Mục đích: Màn hình Chat.
/// Vị trí: lib/presentation/screens/chat/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import 'chat_ui.dart';
import '../../../core/di/injection.dart';

class ChatScreen extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ChatScreen({
    Key? key,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              sl<ChatBloc>()..add(ChatLoadRequested(projectId: projectId)),
      child: ChatScreenUI(projectId: projectId, projectName: projectName),
    );
  }
}
