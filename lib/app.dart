import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/network/connectivity_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_planner/presentations/screens/generate_plan_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/legal/privacy_policy_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/study_plan/presentation/screens/home_screen.dart';
import 'features/study_plan/presentation/screens/plan_detail_screen.dart';
import 'features/study_plan/presentation/screens/daily_plan_screen.dart';
import 'features/pomodoro/presentation/screens/pomodoro_screen.dart';
import 'features/progress/presentation/screens/progress_screen.dart';
import 'features/ai_chat/presentation/screens/chat_screen.dart';
import 'features/analytics/presentation/screens/analytics_screen.dart';

class PrepwiseApp extends ConsumerWidget {
  const PrepwiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineAsync = ref.watch(connectivityOnlineProvider);
    final showOfflineBanner = onlineAsync.when(
      data: (online) => !online,
      loading: () => false,
      error: (_, __) => false,
    );

    return MaterialApp(
      title: 'AI Study Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/generate': (_) => const GeneratePlanScreen(),
        '/plan': (_) => const HomeScreen(),
        '/plan-detail': (_) => const PlanDetailScreen(),
        '/daily': (_) => const DailyPlanScreen(),
        '/pomodoro': (_) => const PomodoroScreen(),
        '/progress': (_) => const ProgressScreen(),
        '/chat': (_) => const ChatScreen(),
        '/analytics': (_) => const AnalyticsScreen(),
        '/privacy': (_) => const PrivacyPolicyScreen(),
      },
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.scale(1.0).clamp(0.88, 1.15);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(clamped)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              child ?? const SizedBox.shrink(),
              if (showOfflineBanner)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: AppColors.hard,
                    elevation: 4,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No network connection. Check Wi‑Fi or mobile data.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
