import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_planner/presentations/screens/generate_plan_screen.dart';
import 'providers/theme_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/study_plan/presentation/screens/study_plan_screen.dart';
import 'features/study_plan/presentation/screens/daily_plan_screen.dart';
import 'features/pomodoro/presentation/screens/pomodoro_screen.dart';
import 'features/progress/presentation/screens/progress_screen.dart';
import 'features/ai_chat/presentation/screens/chat_screen.dart';
import 'features/analytics/presentation/screens/analytics_screen.dart';

class PrepwiseApp extends ConsumerWidget {
  const PrepwiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Prepwise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login':      (_) => const LoginScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/generate':   (_) => const GeneratePlanScreen(),
        '/plan':       (_) => const StudyPlanScreen(),
        '/daily':      (_) => const DailyPlanScreen(),
        '/pomodoro':   (_) => const PomodoroScreen(),
        '/progress':   (_) => const ProgressScreen(),
        '/chat':       (_) => const ChatScreen(),
        '/analytics':  (_) => const AnalyticsScreen(),
      },
    );
  }
}
