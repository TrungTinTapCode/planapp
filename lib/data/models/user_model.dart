/// Mục đích: Model dữ liệu cho User (data layer).
/// Vị trí: lib/data/models/user_model.dart

// TODO: Định nghĩa UserModel

import '../../domain/entities/user.dart';

/// Model ánh xạ dữ liệu người dùng từ Firebase.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
