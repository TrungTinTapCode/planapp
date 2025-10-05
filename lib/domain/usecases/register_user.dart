import '../repositories/auth_repository.dart';
import '../entities/user.dart';

/// UseCase: Đăng ký người dùng mới
class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity> call(String email, String password, String name) {
    return repository.register(email, password, name);
  }
}
