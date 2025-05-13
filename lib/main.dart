import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/connectivity_plus.dart';
import 'features/auth/app_auth_provider.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/presentation/screens/add_task_screen.dart';
import 'features/tasks/presentation/screens/task_detail_screen.dart';
import 'features/tasks/presentation/screens/task_list_screen.dart';
import 'features/tasks/task_provider.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({required this.showOnboarding, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ChangeNotifierProvider<AppAuthProvider>(
          create: (context) => AppAuthProvider(
            authRepo: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'TaskMeNot',
        theme: ThemeData(
          fontFamily: AppTextStyles.jakartaSans,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) {
            return Stack(
              children: [
                const SplashScreen(), // Your initial screen
                Consumer<ConnectivityProvider>(
                  builder: (context, provider, _) {
                    if (!provider.isConnected) {
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.all(12),
                          child: const SafeArea(
                            child: Center(
                              child: Text(
                                'No Internet Connection',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
        // <-- Set splash as initial screen
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/auth-wrapper': (context) => const AuthWrapper(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/add-task': (context) => const AddTaskScreen(),
          '/tasks': (context) => const TaskListScreen(),
          '/task-detail': (context) {
            final task = ModalRoute.of(context)!.settings.arguments as Task;
            return TaskDetailScreen(task: task);
          },
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AppAuthProvider>().currentUser;

    if (currentUser != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}