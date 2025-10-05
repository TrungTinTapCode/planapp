/// Mục đích: Service tương tác với Firebase Auth (data layer).
/// Vị trí: lib/data/datasources/firebase/auth_service.dart

// TODO: Thêm các method đăng nhập/đăng ký ở đây

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService(this._auth, this._firestore);

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

    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'email': email,
      'name': name,
      'role': 'member',
    });

    return UserModel(id: user.uid, email: email, name: name);
  }

  Future<void> logout() async => _auth.signOut();

  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(id: user.uid, email: user.email ?? '');
  }
}


