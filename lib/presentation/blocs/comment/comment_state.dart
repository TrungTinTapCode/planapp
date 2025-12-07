import 'package:equatable/equatable.dart';
import 'package:planapp/data/models/task_comment_model.dart';

abstract class CommentState extends Equatable {
  const CommentState();
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoadSuccess extends CommentState {
  final List<TaskCommentModel> comments;
  const CommentLoadSuccess(this.comments);
  @override
  List<Object?> get props => [comments];
}

class CommentOperationFailure extends CommentState {
  final String message;
  const CommentOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class CommentAddedSuccess extends CommentState {}
