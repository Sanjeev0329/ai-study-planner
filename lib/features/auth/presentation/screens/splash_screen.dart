import 'dart:math' as math;
import 'dart:ui';
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

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const _minSplash = Duration(milliseconds: 2800);

  late final AnimationController _logoCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _ringCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _logoFade = CurvedAnimation(
      parent: _logoCtrl,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _logoCtrl,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.35, 1, curve: Curves.easeOutCubic)),
    );

    _logoCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    String route = '/login';

    try {
      final auth = ref.read(authServiceProvider);
      final firebaseUser = auth.currentUser;

      if (firebaseUser != null) {
        ref.read(userProvider.notifier).setUser(auth.userModelFromFirebase(firebaseUser));
        await ref.read(plansListProvider.notifier).load();

        final cached = await LocalStorageService.getCachedPlan();
        if (cached != null) {
          ref.read(studyPlanProvider.notifier).setPlan(StudyPlanModel.fromMap(cached));
        }

        final onboarded = await LocalStorageService.isOnboarded();
        route = onboarded ? '/plan' : '/onboarding';
      }
    } catch (_) {
      route = '/login';
    }

    final elapsed = DateTime.now().difference(started);
    if (elapsed < _minSplash) {
      await Future<void>.delayed(_minSplash - elapsed);
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B1120),
                  AppColors.bgPrimary,
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),
          _buildOrbs(),
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, __) => CustomPaint(
              painter: _CircuitRingPainter(rotation: _ringCtrl.value * 2 * math.pi),
              size: Size.infinite,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1).animate(_logoScale),
                    child: _buildLogo(),
                  ),
                ),
                const SizedBox(height: 36),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.accentCyan, AppColors.textWhite, AppColors.primaryLight],
                          ).createShader(bounds),
                          child: const Text(
                            'AI STUDY',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'P L A N N E R',
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 8,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your intelligent path to exam success',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.accentCyan.withValues(
                            alpha: 0.6 + 0.4 * _pulseCtrl.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Initializing AI engine…',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, child) {
        final glow = 0.35 + 0.25 * _pulseCtrl.value;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentCyan.withValues(alpha: glow),
                blurRadius: 48 + 16 * _pulseCtrl.value,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: glow * 0.7),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.accentCyan.withValues(alpha: 0.35),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.bgSecondary.withValues(alpha: 0.8),
                  AppColors.bgPrimary.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/images/aistudyicon.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: AppColors.bgSecondary,
                  child: const Icon(Icons.auto_awesome, size: 56, color: AppColors.accentCyan),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrbs() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _orb(AppColors.primary, 200, 0.25 + 0.1 * _pulseCtrl.value),
          ),
          Positioned(
            bottom: 80,
            left: -50,
            child: _orb(AppColors.accentCyan, 160, 0.2 + 0.1 * (1 - _pulseCtrl.value)),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class _CircuitRingPainter extends CustomPainter {
  final double rotation;

  _CircuitRingPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.38;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.accentCyan.withValues(alpha: 0.08);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawCircle(Offset.zero, radius, paint);

    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2, paint..color = AppColors.primary.withValues(alpha: 0.2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CircuitRingPainter old) => old.rotation != rotation;
}
