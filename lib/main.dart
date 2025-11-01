import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection.dart';
import 'data/datasources/firebase/messaging_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/project/project_bloc.dart';
import 'presentation/blocs/task/task_bloc.dart';
import 'presentation/blocs/notification/notification_bloc.dart';
import 'presentation/blocs/notification/notification_event.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initDependencies();

  // Khởi tạo MessagingService (xin quyền + foreground handler)
  await sl.get<MessagingService>().initialize();

  runApp(const PlanApp());
}

class PlanApp extends StatelessWidget {
  const PlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        BlocProvider<ProjectBloc>(create: (context) => sl<ProjectBloc>()),
        BlocProvider<TaskBloc>(create: (context) => sl<TaskBloc>()),
        BlocProvider<NotificationBloc>(
          create: (context) => sl<NotificationBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => curr is AuthAuthenticated,
            listener: (context, state) async {
              if (state is AuthAuthenticated) {
                // Đăng ký device token cho user và bắt đầu lắng nghe thông báo
                await sl.get<MessagingService>().ensureUserToken(state.user.id);
                context.read<NotificationBloc>().add(
                  NotificationStartListening(state.user.id),
                );
              }
            },
          ),
        ],
        child: MaterialApp(
          title: 'PlanApp',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Xử lý điều hướng dựa trên auth state
              if (state is AuthAuthenticated) {
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
