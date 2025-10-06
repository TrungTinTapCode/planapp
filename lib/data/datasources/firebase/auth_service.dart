// Service xử lý các tác vụ xác thực với Firebase Auth
// Vị trí: lib/data/datasources/firebase/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Khởi tạo service với FirebaseAuth và FirebaseFirestore instances
  AuthService(this._auth, this._firestore);

  // Đăng nhập người dùng với email và mật khẩu
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    return UserModel(id: user.uid, email: user.email ?? '');
  }

  // Đăng ký tài khoản người dùng mới
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;

    // Lưu thông tin người dùng vào Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'email': email,
      'name': name,
      'role': 'member',
    });

    return UserModel(id: user.uid, email: email, name: name);
  }

  // Đăng xuất người dùng khỏi Firebase Auth
  Future<void> logout() async => await _auth.signOut();

  // Lấy thông tin người dùng hiện tại đang đăng nhập
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(id: user.uid, email: user.email ?? '');
  }
}