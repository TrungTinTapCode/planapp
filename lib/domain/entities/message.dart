/// Mục đích: Entity Message cho tầng domain.
/// Vị trí: lib/domain/entities/message.dart

class MessageEntity {
  final String id;
  final String projectId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type; // text, image, file

  MessageEntity({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
  });
}

enum MessageType { text, image, file }