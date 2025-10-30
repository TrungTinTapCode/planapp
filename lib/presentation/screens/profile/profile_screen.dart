// Màn hình Cá nhân (embedded trong TabBar)
// Vị trí: lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'profile_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false; // Placeholder toggle
  bool _pushEnabled = true; // Placeholder toggle

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String displayName = '';
        String email = '';
        String? photoUrl;

        if (state is AuthAuthenticated) {
          displayName = state.user.displayName;
          email = state.user.email;
          photoUrl = state.user.photoUrl;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileUIComponents.header(
              photoUrl: photoUrl,
              displayName: displayName.isNotEmpty ? displayName : 'Người dùng',
              email: email,
            ),
            const SizedBox(height: 16),
            ProfileUIComponents.sectionTitle('Tài khoản'),
            ProfileUIComponents.tile(
              icon: Icons.person_outline,
              title: 'Chỉnh sửa hồ sơ',
              subtitle: 'Tên hiển thị, ảnh đại diện',
              onTap: () => _notImplemented(context),
            ),
            ProfileUIComponents.tile(
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              onTap: () => _notImplemented(context),
            ),
            const SizedBox(height: 8),
            ProfileUIComponents.sectionTitle('Cài đặt'),
            ProfileUIComponents.tile(
              icon: Icons.dark_mode_outlined,
              title: 'Chế độ tối',
              trailing: Switch(
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
            ),
            ProfileUIComponents.tile(
              icon: Icons.notifications_active_outlined,
              title: 'Thông báo đẩy',
              trailing: Switch(
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
              ),
            ),
          ],
        );
      },
    );
  }

  void _notImplemented(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
  }
}
