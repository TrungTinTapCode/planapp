// Màn hình đăng ký - logic và state management
// Vị trí: lib/presentation/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'signup_ui.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SignupScreenContent();
  }
}

class _SignupScreenContent extends StatefulWidget {
  const _SignupScreenContent();

  @override
  State<_SignupScreenContent> createState() => _SignupScreenContentState();
}

class _SignupScreenContentState extends State<_SignupScreenContent> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // ✅ THÊM USERNAME
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose(); // ✅ DISPOSE USERNAME
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Debug log (bỏ/giảm sau khi fix)
          // ignore: avoid_print
          print('SignupScreen listener state: $state');

          if (state is AuthAuthenticated) {
            // Khi nhận AuthAuthenticated, điều hướng tới HomeScreen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng ký thành công!')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is AuthError) {
            _showErrorSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildSignupContent(context);
        },
      ),
    );
  }

  // Xây dựng nội dung màn hình đăng ký
  Widget _buildSignupContent(BuildContext context) {
    final isLoading = context.watch<AuthBloc>().state is AuthLoading;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SignupUIComponents.signupHeader(),
          SignupUIComponents.signupForm(
            nameController: _nameController,
            usernameController: _usernameController, // ✅ TRUYỀN USERNAME
            emailController: _emailController,
            passwordController: _passwordController,
            onSignup: () => _handleSignup(context),
            isLoading: isLoading, // ✅ Sử dụng trực tiếp
          ),
          const SizedBox(height: 20),
          SignupUIComponents.loginLink(onTap: () => _navigateToLogin(context)),
        ],
      ),
    );
  }

  // Xử lý sự kiện đăng ký
  void _handleSignup(BuildContext context) {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim(); // ✅ LẤY USERNAME
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorSnackbar(context, 'Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (username.length < 3) {
      _showErrorSnackbar(context, 'Tên tài khoản phải có ít nhất 3 ký tự');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackbar(context, 'Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    // ✅ TRUYỀN USERNAME LÀM displayName
    context.read<AuthBloc>().add(
      AuthRegisterRequested(email, password, username),
    );
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

  // Điều hướng sang màn hình đăng nhập
  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
