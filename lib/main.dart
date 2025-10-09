import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/project/project_bloc.dart';
import 'presentation/blocs/task/task_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initDependencies();

  runApp(const PlanApp());
}

class PlanApp extends StatelessWidget {
  const PlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        // ✅ THÊM PROJECT BLOC VÀO PROVIDERS
        BlocProvider<ProjectBloc>(create: (context) => sl<ProjectBloc>()),
        // TaskBloc provided at app level so features can dispatch task events
        BlocProvider(create: (context) => sl<TaskBloc>()),
      ],
      child: MaterialApp(
        title: 'PlanApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            print('Auth State in Main: $state'); // Debug

            // Xử lý điều hướng dựa trên auth state
            if (state is AuthAuthenticated) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
