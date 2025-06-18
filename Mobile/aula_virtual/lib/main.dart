import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/services/auth_service.dart';
import 'core/providers/fcm_provider.dart';
import 'core/providers/profesor_provider.dart';  // 🔥 AGREGAR ESTA LÍNEA
import 'core/providers/estudiante_provider.dart';
import 'core/providers/tutor_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'features/profesor/views/profesor_dashboard.dart';
import 'features/estudiante/views/estudiante_dashboard.dart';
import 'features/tutor/views/tutor_dashboard.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  // 🔥 Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔥 FCM Provider primero
        ChangeNotifierProvider(
          create: (_) {
            final fcmProvider = FCMProvider();
            // Inicializar FCM automáticamente
            fcmProvider.initializeFCM();
            return fcmProvider;
          },
        ),
        
        // 🔥 AGREGAR ProfesorProvider
        ChangeNotifierProvider(
          create: (_) => ProfesorProvider(),
        ),
        // 🔥 AGREGAR EstudianteProvider
        ChangeNotifierProvider(
          create: (_) => EstudianteProvider(),
        ),
        // 🔥 Auth Service con acceso al FCM Provider
        ChangeNotifierProxyProvider<FCMProvider, AuthService>(
          create: (_) => AuthService(),
          update: (context, fcmProvider, authService) {
            if (authService != null) {
              authService.setFCMProvider(fcmProvider);
              authService.init();
            }
            return authService ?? AuthService();
          },
        ),
         ChangeNotifierProvider(
          create: (_) => TutorProvider(),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          final router = GoRouter(
            initialLocation: '/',
            redirect: (context, state) {
              final isLoggedIn = auth.isLoggedIn;
              final isGoingToLogin = state.matchedLocation == '/login';
              
              // Si no está logueado y no va al login, redirigir al login
              if (!isLoggedIn && !isGoingToLogin) {
                return '/login';
              }
              
              // Si está logueado y va al login, redirigir al dashboard según rol
              if (isLoggedIn && isGoingToLogin) {
                return _getDashboardRoute(auth.userRole);
              }
              
              return null;
            },
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => LoginScreen(),
              ),
              GoRoute(
                path: '/',
                redirect: (context, state) => '/login',
              ),
              GoRoute(
                path: '/profesor',
                builder: (context, state) => ProfesorDashboard(),
              ),
              GoRoute(
                path: '/estudiante',
                builder: (context, state) => EstudianteDashboard(),
              ),
              GoRoute(
                path: '/tutor',
                builder: (context, state) => TutorDashboard(),
              ),
            ],
          );

          return MaterialApp.router(
            title: 'Aula Virtual',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  String _getDashboardRoute(String? role) {
    switch (role?.toLowerCase()) {
      case 'profesor':
        return '/profesor';
      case 'estudiante':
        return '/estudiante';
      case 'tutor':
        return '/tutor';
      default:
        return '/login';
    }
  }
}
