import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../widgets/message_bubble_widget.dart';
import '../../../domain/entities/message.dart';
import '../../../core/di/injection.dart';
import '../../../data/datasources/firebase/project_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final Map<String, String> _memberNames = {}; // userId -> displayName

  @override
  void initState() {
    super.initState();
    _loadMemberNames();
    // Request load
    context.read<ChatBloc>().add(
      ChatLoadRequested(projectId: widget.projectId),
    );
    // autofocus input shortly after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadMemberNames() async {
    try {
      final projectService = sl<ProjectService>();
      final members = await projectService.getMembers(widget.projectId);
      for (final m in members) {
        final id = m['id'] as String?;
        final displayName =
            (m['displayName'] as String?) ?? (m['name'] as String?);
        final email = m['email'] as String?;
        if (id != null && displayName != null) {
          _memberNames[id] = displayName;
        }
        if (email != null && displayName != null) {
          // also map by email for older messages that used email as senderId
          _memberNames[email] = displayName;
        }
      }
      // debug
      // ignore: avoid_print
      print(
        'ChatScreenUI: loaded member names: ${_memberNames.length} entries',
      );
      setState(() {});
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load chat member names: $e');
    }
  }

  // Ensure we have display names for all senders in messages; will fetch user docs by email if needed
  Future<void> _ensureNamesForMessages(List<MessageEntity> messages) async {
    final projectService = sl<ProjectService>();
    final firestore = sl<FirebaseFirestore>();
    for (final m in messages) {
      final sid = m.senderId;
      final sname = m.senderName;
      if (_memberNames.containsKey(sid) || _memberNames.containsKey(sname))
        continue;

      String? foundName;

      try {
        // If senderId looks like an email, try to find uid
        if (sid.contains('@')) {
          final uid = await projectService.getUserIdByEmail(sid);
          if (uid != null) {
            final doc = await firestore.collection('users').doc(uid).get();
            if (doc.exists)
              foundName = (doc.data()?['displayName'] as String?) ?? foundName;
            if (foundName != null) {
              _memberNames[uid] = foundName;
              _memberNames[sid] = foundName; // cache by email too
            }
          }
        }

        // try by senderName if it's an email
        if (foundName == null && sname.contains('@')) {
          final uid2 = await projectService.getUserIdByEmail(sname);
          if (uid2 != null) {
            final doc2 = await firestore.collection('users').doc(uid2).get();
            if (doc2.exists)
              foundName = (doc2.data()?['displayName'] as String?) ?? foundName;
            if (foundName != null) {
              _memberNames[uid2] = foundName;
              _memberNames[sname] = foundName;
            }
          }
        }

        // last resort: query users collection by email equals sname or sid
        if (foundName == null) {
          final q1 =
              await firestore
                  .collection('users')
                  .where('email', isEqualTo: sname)
                  .limit(1)
                  .get();
          if (q1.docs.isNotEmpty) {
            final d = q1.docs.first.data();
            foundName = (d['displayName'] as String?) ?? foundName;
            if (foundName != null) {
              _memberNames[sname] = foundName;
            }
          }
        }
        if (foundName == null) {
          final q2 =
              await firestore
                  .collection('users')
                  .where('email', isEqualTo: sid)
                  .limit(1)
                  .get();
          if (q2.docs.isNotEmpty) {
            final d = q2.docs.first.data();
            foundName = (d['displayName'] as String?) ?? foundName;
            if (foundName != null) {
              _memberNames[sid] = foundName;
            }
          }
        }
      } catch (e) {
        // ignore
      }
    }
    if (mounted) setState(() {});
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
                  // try to ensure we have display names cached for these messages
                  _ensureNamesForMessages(messages);
                  // auto-scroll to bottom when messages change
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      // Determine whether message is from current user
                      final currentUser = sl<GetCurrentUser>().execute();
                      final isMe =
                          (currentUser?.id == m.senderId) ||
                          (currentUser?.email == m.senderId) ||
                          (currentUser?.email == m.senderName);

                      // try to resolve display name by senderId first, then by senderName (email)
                      final resolvedName =
                          _memberNames[m.senderId] ??
                          _memberNames[m.senderName];

                      // If current user hasn't seen this message, mark it as seen
                      final currentUid = sl<GetCurrentUser>().execute()?.id;
                      if (currentUid != null &&
                          !m.seenBy.contains(currentUid)) {
                        context.read<ChatBloc>().add(
                          ChatMarkSeenRequested(
                            projectId: widget.projectId,
                            messageId: m.id,
                            userId: currentUid,
                          ),
                        );
                      }

                      // compute seenBy display names
                      final seenByNames =
                          m.seenBy.map((uid) {
                            return _memberNames[uid] ??
                                (uid.contains('@')
                                    ? uid.split('@').first
                                    : uid);
                          }).toList();

                      return MessageBubbleWidget(
                        message: m,
                        isMe: isMe,
                        displayNameOverride: resolvedName,
                        seenByNames: seenByNames,
                      );
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
                      focusNode: _focusNode,
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
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
    // refocus the input
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
