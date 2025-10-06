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
  })  : _loginUser = loginUser,
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
    try {
      final user = await _loginUser.execute(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Xử lý event đăng ký
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _registerUser.execute(
        event.email, 
        event.password, 
        event.name
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Xử lý event đăng xuất
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _logoutUser.execute();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}