// Màn hình tạo project mới - logic và state management
// Vị trí: lib/presentation/screens/project/create_project_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/project/project_bloc.dart';
import '../../blocs/project/project_event.dart';
import '../../blocs/project/project_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'create_project_ui.dart';

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CreateProjectScreenContent();
  }
}

class _CreateProjectScreenContent extends StatefulWidget {
  const _CreateProjectScreenContent();

  @override
  State<_CreateProjectScreenContent> createState() => _CreateProjectScreenContentState();
}

class _CreateProjectScreenContentState extends State<_CreateProjectScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreateProjectUI.appBar(),
      body: _buildCreateProjectForm(),
    );
  }

  // Xây dựng form tạo project
  Widget _buildCreateProjectForm() {
    return BlocListener<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectError) {
          _showErrorSnackbar(context, state.message);
        }
        // Khi tạo project thành công, quay lại màn hình trước
        if (state is ProjectLoadSuccess) {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CreateProjectUI.projectIcon(),
              const SizedBox(height: 24),
              CreateProjectUI.nameField(
                controller: _nameController,
                onChanged: (_) => _updateCreateButtonState(),
              ),
              const SizedBox(height: 16),
              CreateProjectUI.descriptionField(
                controller: _descriptionController,
                onChanged: (_) => _updateCreateButtonState(),
              ),
              const SizedBox(height: 32),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Xây dựng nút tạo project
  Widget _buildCreateButton() {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final isLoading = state is ProjectLoading;
        final isValid = _nameController.text.trim().isNotEmpty;

        return CreateProjectUI.createButton(
          isLoading: isLoading,
          isValid: isValid,
          onPressed: isLoading ? null : () => _handleCreateProject(context),
        );
      },
    );
  }

  // Cập nhật trạng thái nút tạo project
  void _updateCreateButtonState() {
    setState(() {});
  }

  // Xử lý sự kiện tạo project
  void _handleCreateProject(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final name = _nameController.text.trim();
        final description = _descriptionController.text.trim();

        context.read<ProjectBloc>().add(
          ProjectCreateRequested(
            name: name,
            description: description,
            ownerId: authState.user.id,
          ),
        );
      }
    }
  }

  // Hiển thị lỗi
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}