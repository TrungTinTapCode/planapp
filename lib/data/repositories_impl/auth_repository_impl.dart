// Implementation cụ thể của AuthRepository cho data layer
// Vị trí: lib/data/repositories_impl/auth_repository_impl.dart

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  // Khởi tạo repository với AuthService dependency
  AuthRepositoryImpl(this._authService);

  @override
  // Đăng nhập người dùng - chuyển tiếp yêu cầu đến AuthService
  Future<User> login(String email, String password) =>
      _authService.login(email: email, password: password);

  @override
  // Đăng ký người dùng mới - chuyển tiếp yêu cầu đến AuthService
  Future<User> register(String email, String password, String name) =>
      _authService.register(email: email, password: password, name: name);

  @override
  // Đăng xuất người dùng - chuyển tiếp yêu cầu đến AuthService
  Future<void> logout() => _authService.logout();

  @override
  // Lấy thông tin người dùng hiện tại từ AuthService
  User? getCurrentUser() => _authService.currentUser;
}