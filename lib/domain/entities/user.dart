/// Mục đích: Entity User cho tầng domain.
/// Vị trí: lib/domain/entities/user.dart

// TODO: Định nghĩa User entity

/// Entity biểu diễn thông tin người dùng trong hệ thống.
class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? role;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.role,
  });
}
