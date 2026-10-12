import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:life_drop/config/config.dart';
import 'package:life_drop/theme/app_theme.dart';
import 'package:life_drop/services/mock_data_service.dart';
import 'package:life_drop/services/auth_service.dart';
import 'package:life_drop/screens/main_layout.dart';
import 'package:life_drop/screens/home_screen.dart';
import 'package:life_drop/screens/search_screen.dart';
import 'package:life_drop/screens/history_screen.dart';
import 'package:life_drop/screens/notifications_screen.dart';
import 'package:life_drop/screens/settings_screen.dart';
import 'package:life_drop/screens/patient_dashboard_screen.dart';
import 'package:life_drop/screens/hospital_dashboard_screen.dart';
import 'package:life_drop/screens/donor_dashboard_screen.dart';
import 'package:life_drop/screens/blood_bank_dashboard_screen.dart';
import 'package:life_drop/screens/landing_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockDataService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const VitalPulseApp(),
    ),
  );
}

final GoRouter _appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/landing',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LandingScreen(),
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              final progress = curved.value;
              // 3D Perspective Flip & Scale entrance
              final angle = (1.0 - progress) * (math.pi / 4.0);
              final tiltX = (1.0 - progress) * 0.15;
              final scale = 0.85 + 0.15 * progress;
              final elevation = (1.0 - progress) * 40.0;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(-angle)
                  ..rotateX(tiltX)
                  ..setEntry(0, 0, scale)
                  ..setEntry(1, 1, scale),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (elevation > 0)
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.35 * (1.0 - progress)),
                          blurRadius: elevation,
                          spreadRadius: 2,
                          offset: Offset(0, elevation / 2),
                        ),
                    ],
                  ),
                  child: Opacity(
                    opacity: progress.clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
              );
            },
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/donor-dashboard',
      builder: (context, state) => const DonorDashboardScreen(),
    ),
    GoRoute(
      path: '/patient-dashboard',
      builder: (context, state) => const PatientDashboardScreen(),
    ),
    GoRoute(
      path: '/hospital-dashboard',
      builder: (context, state) => const HospitalDashboardScreen(),
    ),
    GoRoute(
      path: '/blood-bank-dashboard',
      builder: (context, state) => const BloodBankDashboardScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

class VitalPulseApp extends StatelessWidget {
  const VitalPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mockService.appThemeMode,
      routerConfig: _appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
