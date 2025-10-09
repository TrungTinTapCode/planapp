/// Mục đích: Model dữ liệu cho User (data layer).
/// Vị trí: lib/data/models/user_model.dart

import 'package:planapp/domain/entities/user.dart';

/// Model ánh xạ dữ liệu người dùng từ Firestore
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.displayName,
    required super.email,
    super.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
