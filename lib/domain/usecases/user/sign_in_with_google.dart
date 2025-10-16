import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';

class SignInWithGoogle {
  final AuthRepository _authRepository;

  SignInWithGoogle(this._authRepository);

  Future<User> execute() async {
    return await _authRepository.signInWithGoogle();
  }
}
