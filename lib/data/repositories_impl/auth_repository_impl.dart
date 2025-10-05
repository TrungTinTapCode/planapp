import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl(this.authService);

  @override
  Future<UserEntity> login(String email, String password) =>
      authService.login(email: email, password: password);

  @override
  Future<UserEntity> register(String email, String password, String name) =>
      authService.register(email: email, password: password, name: name);

  @override
  Future<void> logout() => authService.logout();

  @override
  UserEntity? getCurrentUser() => authService.currentUser;
}

