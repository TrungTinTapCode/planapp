// UseCase xử lý việc đăng xuất người dùng khỏi hệ thống
// Vị trí: lib/domain/usecases/logout_user.dart

import '../../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository _authRepository;

  // Khởi tạo UseCase với AuthRepository dependency
  LogoutUser(this._authRepository);

  // Thực hiện đăng xuất - không trả về dữ liệu
  Future<void> execute() async {
    return await _authRepository.logout();
  }
}