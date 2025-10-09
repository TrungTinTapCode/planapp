/// Mục đích: Entity User cho tầng domain.
/// Vị trí: lib/domain/entities/user.dart

/// Entity biểu diễn thông tin người dùng trong hệ thống
class User {
  /// ID duy nhất của user
  final String id;

  /// Tên hiển thị của user
  final String displayName;

  /// Email của user
  final String email;

  /// URL ảnh đại diện
  final String? photoUrl;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  /// Copy user với các thuộc tính mới
  User copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
