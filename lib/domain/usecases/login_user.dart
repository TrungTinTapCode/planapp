/// Mục đích: UseCase: Login user.
/// Vị trí: lib/domain/usecases/login_user.dart

// TODO: Implement LoginUser usecase

import '../repositories/auth_repository.dart';
import '../entities/user.dart';

/// UseCase: Đăng nhập người dùng với email & password
class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}
