/// Mục đích: Interface AuthRepository (abstract) cho domain.
/// Vị trí: lib/domain/repositories/auth_repository.dart

// TODO: Định nghĩa abstract class AuthRepository

import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password, String name);
  Future<void> logout();
  UserEntity? getCurrentUser();
}
