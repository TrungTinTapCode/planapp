// Màn hình chính - logic và state management
// Vị trí: lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../auth/login_screen.dart';
import 'home_ui.dart'; // ✅ Import từ widgets folder

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenContent();
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeUIComponents.homeAppBar(
        title: 'Trang chủ',
        onLogout: () => _handleLogout(context),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            _navigateToLoginScreen(context);
          }
        },
        child: const _HomeContent(),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang đăng xuất...')),
    );
  }

  void _navigateToLoginScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final email = state is AuthAuthenticated ? state.user.email : '';
        final isLoading = state is AuthLoading;
        
        return HomeUIComponents.homeContent(email, isLoading);
      },
    );
  }
}