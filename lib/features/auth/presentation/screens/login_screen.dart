import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../providers/app_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../services/storage/local_storage_service.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (!mounted) return;
      if (user == null) { _showError('Invalid email or password.'); return; }
      ref.read(userProvider.notifier).setUser(user);
      final onboarded = await LocalStorageService.isOnboarded();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, onboarded ? '/plan' : '/onboarding');
    } catch (_) {
      if (mounted) _showError('Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      if (user == null) { _showError('Google sign-in cancelled.'); return; }
      ref.read(userProvider.notifier).setUser(user);
      final onboarded = await LocalStorageService.isOnboarded();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, onboarded ? '/plan' : '/onboarding');
    } catch (_) {
      if (mounted) _showError('Google sign-in failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            'Enter your email and we will send a reset link.',
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // ── reusing CustomTextField ──────────────────
          CustomTextField(
            hint: 'you@example.com',
            controller: ctrl,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          // ── reusing CustomButton ─────────────────────
          SizedBox(
            width: 90,
            child: CustomButton(
              label: 'Send',
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                await ref
                    .read(authServiceProvider)
                    .sendPasswordReset(ctrl.text.trim());
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Reset link sent! Check your email.'),
                  backgroundColor: AppColors.easy,
                  behavior: SnackBarBehavior.floating,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.hard,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // ── Logo + title ──────────────────────────
                Center(
                  child: Column(children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text('Welcome back',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    const Text('Sign in to continue studying',
                        style: TextStyle(fontSize: 15, color: AppColors.textGrey)),
                  ]),
                ),

                const SizedBox(height: 40),

                // ── Email (CustomTextField) ───────────────
                const Text('Email',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Password ──────────────────────────────
                // Note: CustomTextField doesn't have obscureText toggle built in,
                // so we extend it here just for the eye icon suffix.
                const Text('Password',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Enter your password',
                  controller: _passCtrl,
                  icon: Icons.lock_outline,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20, color: AppColors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                // ── Forgot password ───────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPassword,
                    child: const Text('Forgot password?',
                        style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  ),
                ),

                const SizedBox(height: 4),

                // ── Sign In (CustomButton) ────────────────
                CustomButton(
                  label: 'Sign In',
                  onPressed: _signInWithEmail,
                  isLoading: _loading,
                ),

                const SizedBox(height: 20),

                // ── OR Divider ────────────────────────────
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ]),

                const SizedBox(height: 20),

                // ── Google (CustomButton outlined style) ──
                CustomButton(
                  label: 'Continue with Google',
                  onPressed: _signInWithGoogle,
                  isLoading: _loading,
                  outlined: true,
                ),

                const SizedBox(height: 36),

                // ── Sign Up link ──────────────────────────
                Center(
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: const Text('Sign Up',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ]),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}