import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasources/firebase/auth_service.dart';
import '../../data/datasources/firebase/project_service.dart';
import '../../data/datasources/firebase/task_service.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/project_repository_impl.dart';
import '../../data/repositories_impl/task_repository_impl.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';

import '../../domain/usecases/user/login_user.dart';
import '../../domain/usecases/user/register_user.dart';
import '../../domain/usecases/user/logout_user.dart';
import '../../domain/usecases/user/get_current_user.dart';
import '../../domain/usecases/user/sign_in_with_google.dart';

import '../../domain/usecases/project/create_project.dart';
import '../../domain/usecases/project/get_projects.dart';
import '../../domain/usecases/project/update_project.dart';
import '../../domain/usecases/project/delete_project.dart';
import '../../domain/usecases/project/add_member_to_project.dart';

import '../../domain/usecases/task/create_task.dart';
import '../../domain/usecases/task/update_task.dart';
import '../../domain/usecases/task/delete_task.dart';
import '../../domain/usecases/task/get_tasks_by_project.dart';
import '../../domain/usecases/task/assign_task.dart';
import '../../domain/usecases/task/set_task_completed.dart';
import '../../domain/usecases/task/get_task_by_id.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/project/project_bloc.dart';
import '../../presentation/blocs/task/task_bloc.dart';
import '../../data/datasources/firebase/chat_service.dart';
import '../../data/repositories_impl/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../presentation/blocs/chat/chat_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ✅ Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ✅ Services
  sl.registerLazySingleton(() => AuthService(sl(), sl()));
  sl.registerLazySingleton(() => ProjectService(sl()));
  sl.registerLazySingleton(() => TaskService(sl()));
  sl.registerLazySingleton(() => ChatService(sl()));

  // ✅ Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));
  ;
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));

  // ✅ Auth UseCases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));

  // ✅ Project UseCases
  sl.registerLazySingleton(() => CreateProject(sl()));
  sl.registerLazySingleton(() => GetProjects(sl()));
  sl.registerLazySingleton(() => UpdateProject(sl()));
  sl.registerLazySingleton(() => DeleteProject(sl()));
  sl.registerLazySingleton(() => AddMemberToProject(sl()));

  // ✅ Task UseCases
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => GetTasksByProject(sl()));
  sl.registerLazySingleton(() => AssignTask(sl()));
  sl.registerLazySingleton(() => SetTaskCompleted(sl()));
  sl.registerLazySingleton(() => GetTaskById(sl()));

  // ✅ Blocs
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      getCurrentUser: sl(),
      signInWithGoogle: sl(),
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

  sl.registerFactory(
    () => TaskBloc(
      createTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
      getTasksByProject: sl(),
      assignTask: sl(),
      setTaskCompleted: sl(),
      getTaskById: sl(),
    ),
  );

  sl.registerFactory(() => ChatBloc(chatRepository: sl()));
}
