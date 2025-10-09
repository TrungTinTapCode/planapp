// UseCase xử lý việc đăng nhập người dùng
// Vị trí: lib/domain/usecases/login_user.dart

import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository _authRepository;

  // Khởi tạo UseCase với AuthRepository dependency
  LoginUser(this._authRepository);

  // Thực hiện đăng nhập với email và password
  Future<UserEntity> execute(String email, String password) async {
    return await _authRepository.login(email, password);
  }
}