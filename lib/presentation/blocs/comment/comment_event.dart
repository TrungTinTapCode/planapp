import 'package:equatable/equatable.dart';

class CommentEvent extends Equatable {
  const CommentEvent();
  @override
  List<Object?> get props => [];
}

class LoadCommentsRequested extends CommentEvent {
  final String projectId;
  final String taskId;
  const LoadCommentsRequested(this.projectId, this.taskId);
  @override
  List<Object?> get props => [projectId, taskId];
}

class AddCommentRequested extends CommentEvent {
  final String projectId;
  final String taskId;
  final String content;
  final String authorId;
  final String authorEmail;
  final String authorDisplayName;
  final String? notifyUserId;
  final String? taskTitle;
  const AddCommentRequested({
    required this.projectId,
    required this.taskId,
    required this.content,
    required this.authorId,
    required this.authorEmail,
    required this.authorDisplayName,
    this.notifyUserId,
    this.taskTitle,
  });
  @override
  List<Object?> get props => [
    projectId,
    taskId,
    content,
    authorId,
    authorEmail,
    authorDisplayName,
    notifyUserId,
    taskTitle,
  ];
}
