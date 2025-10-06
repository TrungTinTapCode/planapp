// Màn hình đăng nhập - logic và state management
// Vị trí: lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'signup_screen.dart';
import 'login_ui.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginScreenContent();
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showErrorSnackbar(context, state.message);
          }
        },
        child: _buildLoginContent(context),
      ),
    );
  }

  // Xây dựng nội dung màn hình đăng nhập
  Widget _buildLoginContent(BuildContext context) {
    final isLoading = context.watch<AuthBloc>().state is AuthLoading;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoginUIComponents.loginHeader(),
          LoginUIComponents.loginForm(
            emailController: _emailController,
            passwordController: _passwordController,
            onLogin: () => _handleLogin(context),
            isLoading: isLoading,
          ),
          const SizedBox(height: 20),
          LoginUIComponents.registerLink(
            onTap: () => _navigateToRegister(context),
          ),
        ],
      ),
    );
  }

  // Xử lý sự kiện đăng nhập
  void _handleLogin(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar(context, 'Vui lòng nhập đầy đủ thông tin');
      return;
    }

    context.read<AuthBloc>().add(AuthLoginRequested(email, password));
  }

  // Hiển thị lỗi
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Điều hướng sang màn hình đăng ký
  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }
}