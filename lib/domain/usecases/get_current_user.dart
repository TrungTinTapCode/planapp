import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _authRepository;

  GetCurrentUser(this._authRepository);

  UserEntity? execute() {
    return _authRepository.getCurrentUser();
  }
}
