import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/app_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../services/storage/local_storage_service.dart';
import '../../../../models/study_plan.dart';
import '../../../study_plan/study_plan_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = ref.read(authServiceProvider);
    final firebaseUser = auth.currentUser;

    if (firebaseUser != null) {
      ref.read(userProvider.notifier).setUser(auth.userModelFromFirebase(firebaseUser));
      await ref.read(plansListProvider.notifier).load();

      final cached = await LocalStorageService.getCachedPlan();
      if (cached != null) {
        ref.read(studyPlanProvider.notifier).setPlan(StudyPlanModel.fromMap(cached));
      }

      if (!mounted) return;
      final onboarded = await LocalStorageService.isOnboarded();
      Navigator.pushReplacementNamed(context, onboarded ? '/plan' : '/onboarding');
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, size: 56, color: AppColors.primary),
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
