import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planapp/data/datasources/firebase/task_service.dart';
import 'package:planapp/data/models/task_comment_model.dart';
import 'comment_event.dart';
import 'comment_state.dart';
import 'package:planapp/domain/entities/user.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final TaskService _taskService;
  StreamSubscription? _sub;

  CommentBloc({required TaskService taskService})
    : _taskService = taskService,
      super(CommentInitial()) {
    on<LoadCommentsRequested>(_onLoad);
    on<AddCommentRequested>(_onAdd);
    on<_CommentsUpdated>(_onCommentsUpdated);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  void _onCommentsUpdated(_CommentsUpdated event, Emitter<CommentState> emit) {
    emit(CommentLoadSuccess(event.comments));
  }

  Future<void> _onLoad(
    LoadCommentsRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    _sub?.cancel();
    _sub = _taskService
        .streamTaskComments(projectId: event.projectId, taskId: event.taskId)
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            final comments =
                snap.docs
                    .map(
                      (d) =>
                          TaskCommentModel.fromJson({...d.data(), 'id': d.id}),
                    )
                    .toList();
            add(_CommentsUpdated(comments));
          },
          onError: (e) {
            emit(CommentOperationFailure(e.toString()));
          },
        );
  }

  Future<void> _onAdd(
    AddCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final model = TaskCommentModel(
        id: '',
        projectId: event.projectId,
        taskId: event.taskId,
        author: User(
          id: event.authorId,
          email: event.authorEmail,
          displayName: event.authorDisplayName,
        ),
        content: event.content,
        createdAt: DateTime.now(),
      );
      await _taskService.addTaskComment(
        projectId: event.projectId,
        taskId: event.taskId,
        comment: model.toJson(),
      );
      if (event.notifyUserId != null && event.taskTitle != null) {
        await _taskService.createCommentNotification(
          notifyUserId: event.notifyUserId!,
          projectId: event.projectId,
          taskId: event.taskId,
          taskTitle: event.taskTitle!,
          commenterId: event.authorId,
          commenterName: event.authorDisplayName,
        );
      }
      // emit(CommentAddedSuccess()); // Removed to keep the stream state active
    } catch (e) {
      emit(CommentOperationFailure(e.toString()));
    }
  }
}

class _CommentsUpdated extends CommentEvent {
  final List<TaskCommentModel> comments;
  const _CommentsUpdated(this.comments);
  @override
  List<Object?> get props => [comments];
}
