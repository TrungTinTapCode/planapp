import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service locator dùng để quản lý dependency trong ứng dụng
final sl = GetIt.instance;

/// Hàm khởi tạo dependency, được gọi ở main.dart
Future<void> initDependencies() async {
  // Firebase instances
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  // TODO: sau này sẽ đăng ký thêm Repository, Bloc, UseCase tại đây
}
