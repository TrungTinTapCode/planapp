// UseCase xử lý việc đăng ký tài khoản người dùng mới
// Vị trí: lib/domain/usecases/register_user.dart

import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository _authRepository;

  // Khởi tạo UseCase với AuthRepository dependency
  RegisterUser(this._authRepository);

  // Thực hiện đăng ký user mới với email, password và name
  Future<User> execute(String email, String password, String name) async {
    return await _authRepository.register(email, password, name);
  }
}