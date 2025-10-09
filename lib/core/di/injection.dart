import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasources/firebase/auth_service.dart';
import '../../data/datasources/firebase/project_service.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/project_repository_impl.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/project_repository.dart';

import '../../domain/usecases/user/login_user.dart';
import '../../domain/usecases/user/register_user.dart';
import '../../domain/usecases/user/logout_user.dart';
import '../../domain/usecases/user/get_current_user.dart';

import '../../domain/usecases/project/create_project.dart';
import '../../domain/usecases/project/get_projects.dart';
import '../../domain/usecases/project/update_project.dart';
import '../../domain/usecases/project/delete_project.dart';
import '../../domain/usecases/project/add_member_to_project.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/project/project_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ✅ Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ✅ Services
  sl.registerLazySingleton(() => AuthService(sl(), sl()));
  sl.registerLazySingleton(() => ProjectService(sl()));

  // ✅ Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ProjectRepository>(() => ProjectRepositoryImpl(sl()));

  // ✅ Auth UseCases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // ✅ Project UseCases
  sl.registerLazySingleton(() => CreateProject(sl()));
  sl.registerLazySingleton(() => GetProjects(sl()));
  sl.registerLazySingleton(() => UpdateProject(sl()));
  sl.registerLazySingleton(() => DeleteProject(sl()));
  sl.registerLazySingleton(() => AddMemberToProject(sl()));

  // ✅ Blocs
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      getCurrentUser: sl(),
    ),
  );

  sl.registerFactory(
    () => ProjectBloc(
      createProject: sl(),
      getProjects: sl(),
      updateProject: sl(),
      deleteProject: sl(),
      addMemberToProject: sl(),
    ),
  );
}
