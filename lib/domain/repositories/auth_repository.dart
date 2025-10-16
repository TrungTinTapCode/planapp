// Interface định nghĩa các phương thức xác thực người dùng
// Vị trí: lib/domain/repositories/auth_repository.dart

import '../entities/user.dart';

abstract class AuthRepository {
  // Đăng nhập người dùng với email và mật khẩu
  Future<User> login(String email, String password);

  // Đăng ký tài khoản người dùng mới
  Future<User> register(String email, String password, String name);

  // Đăng xuất người dùng khỏi hệ thống
  Future<void> logout();

  // Lấy thông tin người dùng hiện tại đang đăng nhập
  User? getCurrentUser();

  // Đăng nhập bằng Google
  Future<User> signInWithGoogle();
}
