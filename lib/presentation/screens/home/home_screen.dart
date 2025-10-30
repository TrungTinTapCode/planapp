// Màn hình chính - logic và state management
// Vị trí: lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../auth/login_screen.dart';
import '../project/project_list_screen.dart';
import 'home_ui.dart';
import '../notification/notification_screen.dart';
import '../profile/profile_screen.dart';

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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: HomeUIComponents.homeAppBar(
          title: 'PlanApp',
          onLogout: () => _handleLogout(context),
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: 'Home', icon: Icon(Icons.home)),
              Tab(text: 'Dự án', icon: Icon(Icons.folder_open)),
              Tab(text: 'Thông báo', icon: Icon(Icons.notifications)),
              Tab(text: 'Cá nhân', icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              _navigateToLoginScreen(context);
            }
          },
          child: const _HomeTabView(),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đang đăng xuất...')));
  }

  void _navigateToLoginScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

class _HomeTabView extends StatelessWidget {
  const _HomeTabView();

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: const [
        _HomeTabContent(),
        ProjectListScreen(embedded: true),
        NotificationScreen(),
        ProfileScreen(),
      ],
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

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

// Đã thay thế placeholder bằng NotificationScreen và ProfileScreen
