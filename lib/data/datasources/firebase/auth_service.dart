// Service xử lý các tác vụ xác thực với Firebase Auth
// Vị trí: lib/data/datasources/firebase/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    // Debug: trước khi signIn
    // ignore: avoid_print
    print('AuthService.login: signing in $email');
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    // Debug: sau khi signIn
    // ignore: avoid_print
    print('AuthService.login: signed in uid=${user.uid}');

    // Cố gắng đọc profile người dùng từ collection 'users'
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      return UserModel.fromJson({
        'id': user.uid,
        'displayName': data['displayName'] ?? data['name'] ?? '',
        'email': user.email ?? data['email'] ?? '',
        'photoUrl': data['photoUrl'],
      });
    }

    return UserModel(
      id: user.uid,
      displayName: user.displayName ?? user.email ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  // Đăng ký tài khoản người dùng mới
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // Debug: trước khi tạo user
    // ignore: avoid_print
    print('AuthService.register: creating user for $email');
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;

    // Debug: sau khi createUser
    // ignore: avoid_print
    print('AuthService.register: created user uid=${user.uid}');

    // Lưu thông tin người dùng vào Firestore
    // Debug: trước khi write to firestore
    // ignore: avoid_print
    print('AuthService.register: writing user to firestore uid=${user.uid}');
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'email': email,
      'displayName': name,
      'role': 'member',
    });

    // Debug: sau khi write
    // ignore: avoid_print
    print('AuthService.register: firestore write complete uid=${user.uid}');

    return UserModel(
      id: user.uid,
      displayName: name,
      email: email,
      photoUrl: null,
    );
  }

  // Đăng xuất người dùng khỏi Firebase Auth
  Future<void> logout() async {
    // Debug: before signOut
    // ignore: avoid_print
    print('AuthService.logout: signing out');
    await _auth.signOut();
    // Debug: after signOut
    // ignore: avoid_print
    print('AuthService.logout: signOut complete');
  }

  // Lấy thông tin người dùng hiện tại đang đăng nhập
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Nếu có document ở Firestore, lấy displayName/photoUrl từ đó
    return UserModel(
      id: user.uid,
      displayName: user.displayName ?? user.email ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  /// Đăng nhập bằng Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Quy trình đăng nhập Google đã bị hủy');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Ensure Firestore user doc exists
      final userDoc = _firestore.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          'id': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? '',
          'role': 'member',
          'photoUrl': user.photoURL,
        });
      }

      return UserModel(
        id: user.uid,
        displayName: user.displayName ?? user.email ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      // Firebase Auth specific errors
      throw Exception('Lỗi xác thực: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Lỗi khi đăng nhập bằng Google: $e');
    }
  }
}
