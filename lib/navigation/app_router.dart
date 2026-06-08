import 'package:go_router/go_router.dart';
import '../features/auth/auth_screen.dart';
import '../features/care/care_today_screen.dart';
import '../features/landing/landing_page.dart';
import '../features/plants/plant_list_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/weather/weather_advice_screen.dart';
import 'app_shell.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),

      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            currentPath: state.uri.path,
            child: child,
          );
        },

        routes: [
          GoRoute(
            path: '/plants',
            builder: (context, state) => const PlantListScreen(),
          ),
          GoRoute(
            path: '/care',
            builder: (context, state) => const CareTodayScreen(),
          ),
          GoRoute(
            path: '/weather',
            builder: (context, state) => const WeatherAdviceScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}