import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_priority.dart';
import '../../../domain/entities/user.dart';
import '../../../data/models/user_model.dart';
import '../../../data/datasources/firebase/project_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final String projectId;
  const CreateTaskScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadline;
  TaskPriority _priority = TaskPriority.medium;
  final _tagsController = TextEditingController();
  final List<String> _tags = [];
  List<UserModel> _members = [];
  UserModel? _selectedAssignee;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final projectService = sl<ProjectService>();
      final users = await projectService.getMembers(widget.projectId);
      setState(() {
        _members = users.map((u) => UserModel.fromJson(u)).toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Task')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      _deadline == null
                          ? 'No deadline'
                          : _deadline!.toLocal().toString(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 5),
                          ),
                        );
                        if (picked != null) setState(() => _deadline = picked);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskPriority>(
                    value: _priority,
                    items:
                        TaskPriority.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (p) => setState(
                          () => _priority = p ?? TaskPriority.medium,
                        ),
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                  const SizedBox(height: 8),
                  if (_members.isNotEmpty)
                    DropdownButtonFormField<UserModel?>(
                      value: _selectedAssignee,
                      decoration: const InputDecoration(labelText: 'Assignee'),
                      items:
                          [null, ..._members]
                              .map(
                                (u) => DropdownMenuItem<UserModel?>(
                                  value: u,
                                  child: Text(
                                    u == null ? 'Unassigned' : u.displayName,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _selectedAssignee = v),
                    ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  // Tags input: show chips and an input to add new tag
                  Text('Tags', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map(
                        (t) => Chip(
                          label: Text(t),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            hintText: 'Add tag',
                          ),
                          onSubmitted: (value) {
                            final tag = value.trim();
                            if (tag.isNotEmpty && !_tags.contains(tag)) {
                              setState(() {
                                _tags.add(tag);
                                _tagsController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final tag = _tagsController.text.trim();
                          if (tag.isNotEmpty && !_tags.contains(tag)) {
                            setState(() {
                              _tags.add(tag);
                              _tagsController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  BlocConsumer<TaskBloc, dynamic>(
                    listener: (context, state) {
                      if (state is TaskOperationSuccess) {
                        Navigator.of(context).pop(true);
                      } else if (state is TaskOperationFailure) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                    },
                    builder: (context, state) {
                      if (state is TaskLoading)
                        return const Center(child: CircularProgressIndicator());
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final id =
                                DateTime.now().millisecondsSinceEpoch
                                    .toString();
                            final task = Task(
                              id: id,
                              projectId: widget.projectId,
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim(),
                              deadline: _deadline,
                              tags: List<String>.from(_tags),
                              priority: _priority,
                              assignee: _selectedAssignee,
                              createdAt: DateTime.now(),
                              creator: User(
                                id: 'unknown',
                                displayName: 'Unknown',
                                email: 'unknown',
                              ),
                            );
                            context.read<TaskBloc>().add(
                              CreateTaskRequested(task),
                            );
                          }
                        },
                        child: const Text('Create'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
