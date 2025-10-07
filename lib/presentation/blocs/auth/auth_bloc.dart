// Bloc quản lý state cho quá trình xác thực người dùng
// Vị trí: lib/presentation/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_user.dart';
import '../../../domain/usecases/register_user.dart';
import '../../../domain/usecases/logout_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final LogoutUser _logoutUser;

  // Khởi tạo AuthBloc với các UseCases cần thiết
  AuthBloc({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required LogoutUser logoutUser,
  }) : _loginUser = loginUser,
       _registerUser = registerUser,
       _logoutUser = logoutUser,
       super(AuthInitial()) {
    // Đăng ký các event handlers
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  // Xử lý event đăng nhập
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // Debug: log receipt of login event
    // ignore: avoid_print
    print('AuthBloc: LoginRequested -> email=${event.email}');
    try {
      final user = await _loginUser.execute(event.email, event.password);
      // Debug: successful login
      // ignore: avoid_print
      print('AuthBloc: LoginUser returned user id=${user.id}');
      emit(AuthAuthenticated(user));
    } catch (e, st) {
      // Debug: print error
      // ignore: avoid_print
      print('AuthBloc: Login error: $e\n$st');
      emit(AuthError(e.toString()));
    }
  }

  // Xử lý event đăng ký
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // Debug: log receipt of register event
    // ignore: avoid_print
    print(
      'AuthBloc: RegisterRequested -> email=${event.email}, name=${event.name}',
    );
    try {
      final user = await _registerUser.execute(
        event.email,
        event.password,
        event.name,
      );
      // Debug: successful usecase result
      // ignore: avoid_print
      print('AuthBloc: RegisterUser returned user id=${user.id}');
      emit(AuthAuthenticated(user));
    } catch (e, st) {
      // Debug: print error and stack
      // ignore: avoid_print
      print('AuthBloc: Register error: $e\n$st');
      emit(AuthError(e.toString()));
    }
  }

  // Xử lý event đăng xuất
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // Debug: logout requested
    // ignore: avoid_print
    print('AuthBloc: LogoutRequested');
    try {
      await _logoutUser.execute();
      // ignore: avoid_print
      print('AuthBloc: Logout executed');
      emit(AuthLoggedOut());
      // After logging out, also emit AuthInitial to reset state consumers if needed
      emit(AuthInitial());
    } catch (e, st) {
      // ignore: avoid_print
      print('AuthBloc: Logout error: $e\n$st');
      emit(AuthError(e.toString()));
    }
  }
}
