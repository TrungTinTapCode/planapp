/// Mục đích: Widget hiển thị bong bóng tin nhắn.
/// Vị trí: lib/presentation/widgets/message_bubble_widget.dart

// TODO: Implement MessageBubbleWidget
import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';

class MessageBubbleWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final String? displayNameOverride;
  final List<String>? seenByNames;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    this.isMe = false,
    this.displayNameOverride,
    this.seenByNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.blue : Colors.grey.shade200;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textColor = isMe ? Colors.white : Colors.black87;
    final displayName = displayNameOverride ?? message.senderName;
    final displayLabel =
        (displayName.contains('@'))
            ? displayName.split('@').first
            : displayName;

    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                child: CircleAvatar(
                  child: Text(
                    displayLabel.isNotEmpty
                        ? displayLabel[0].toUpperCase()
                        : '?',
                  ),
                ),
              ),
            Expanded(
              child: Container(
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
                      displayLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(message.content, style: TextStyle(color: textColor)),
                    const SizedBox(height: 6),
                    if (isMe &&
                        (seenByNames != null && seenByNames!.isNotEmpty))
                      Text(
                        'Đã xem bởi ${seenByNames!.join(', ')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                child: CircleAvatar(
                  child: Text(
                    displayLabel.isNotEmpty
                        ? displayLabel[0].toUpperCase()
                        : '?',
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Text(
            _formatTimestamp(message.timestamp.toLocal()),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final local = ts;
    final difference = now.difference(local);

    String timePart = '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';

    if (difference.inDays == 0 && now.day == local.day) {
      return 'Hôm nay $timePart';
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != local.day)) {
      return 'Hôm qua $timePart';
    } else {
      final yearPart = (now.year == local.year) ? '' : ' ${local.year}';
      final datePart =
          '${_twoDigits(local.day)}/${_twoDigits(local.month)}$yearPart';
      return '$datePart $timePart';
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
