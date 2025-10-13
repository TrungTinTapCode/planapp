import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.projectId,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.timestamp,
    super.type = MessageType.text,
    super.seenBy = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      projectId: json['projectId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      seenBy:
          (json['seenBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'seenBy': seenBy,
      'type': type.name,
    };
  }

  factory MessageModel.fromEntity(MessageEntity e) {
    return MessageModel(
      id: e.id,
      projectId: e.projectId,
      senderId: e.senderId,
      senderName: e.senderName,
      content: e.content,
      timestamp: e.timestamp,
      type: e.type,
      seenBy: e.seenBy,
    );
  }

  MessageEntity toEntity() => this;
}
