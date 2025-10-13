/// Mục đích: Widget hiển thị bong bóng tin nhắn.
/// Vị trí: lib/presentation/widgets/message_bubble_widget.dart

// TODO: Implement MessageBubbleWidget
import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';

class MessageBubbleWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    this.isMe = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.blue : Colors.grey.shade200;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(message.content, style: TextStyle(color: textColor)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Text(
            '${message.timestamp.toLocal()}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
