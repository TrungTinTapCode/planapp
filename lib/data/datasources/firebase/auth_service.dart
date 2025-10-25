// Service xử lý các tác vụ xác thực với Firebase Auth
// Vị trí: lib/data/datasources/firebase/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/google_oauth.dart';
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
      String displayName =
          data['displayName'] as String? ??
          data['name'] as String? ??
          user.email?.split('@')[0] ??
          'User';

      // Nếu displayName đang thiếu hoặc rỗng, cập nhật vào Firestore
      if ((data['displayName'] == null ||
              (data['displayName'] as String).isEmpty) &&
          user.email != null) {
        displayName = user.email!.split('@')[0];
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
        });
        print('Updated missing displayName for user: $displayName');
      }

      return UserModel.fromJson({
        'id': user.uid,
        'displayName': displayName,
        'email': user.email ?? data['email'] ?? '',
        'photoUrl': data['photoUrl'],
      });
    }

    return UserModel(
      id: user.uid,
      displayName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
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
      final googleSignIn = GoogleSignIn(
        // serverClientId giúp một số thiết bị tránh lỗi DEVELOPER_ERROR
        serverClientId: googleWebClientId,
        scopes: const ['email', 'profile'],
      );
      // Force sign out trước khi sign in để tránh cached account issues
      await googleSignIn.signOut();
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
        // Tạo mới user document - ✅ DÙNG DISPLAYNAME TỪ GOOGLE
        await userDoc.set({
          'id': user.uid,
          'email': user.email,
          'displayName':
              user.displayName ?? user.email?.split('@')[0] ?? 'User',
          'role': 'member',
          'photoUrl': user.photoURL,
        });
        print('✅ Created Google user with displayName: ${user.displayName}');
      } else {
        // Cập nhật displayName nếu đang thiếu hoặc khác với Google
        final data = snapshot.data()!;
        final existingDisplayName = data['displayName'] as String?;

        // Nếu Google có displayName và khác với Firestore, cập nhật
        if (user.displayName != null &&
            (existingDisplayName == null ||
                existingDisplayName.isEmpty ||
                existingDisplayName != user.displayName)) {
          await userDoc.update({'displayName': user.displayName});
          print('✅ Updated displayName to Google name: ${user.displayName}');
        } else if (existingDisplayName == null || existingDisplayName.isEmpty) {
          // Nếu không có displayName, tạo từ email
          final fallbackName = user.email?.split('@')[0] ?? 'User';
          await userDoc.update({'displayName': fallbackName});
          print('✅ Set fallback displayName: $fallbackName');
        }
      }

      // Đọc lại để đảm bảo có displayName
      final updatedSnapshot = await userDoc.get();
      final userData = updatedSnapshot.data()!;

      return UserModel(
        id: user.uid,
        displayName: userData['displayName'] as String? ?? user.email ?? 'User',
        email: user.email ?? '',
        photoUrl: userData['photoUrl'] as String?,
      );
    } on FirebaseAuthException catch (e) {
      // Firebase Auth specific errors
      throw Exception('Lỗi xác thực Firebase: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Lỗi khi đăng nhập bằng Google: $e');
    }
  }
}
