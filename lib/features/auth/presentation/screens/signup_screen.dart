import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../providers/app_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../services/storage/local_storage_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _loading        = false;
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await ref.read(authServiceProvider).signUpWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
        _nameCtrl.text.trim(),
      );
      if (!mounted) return;
      if (user == null) { _showError('Sign up failed. Email may already be in use.'); return; }
      ref.read(userProvider.notifier).setUser(user);
      await LocalStorageService.setOnboarded(false);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    } catch (_) {
      if (mounted) _showError('Sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _loading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      if (user == null) { _showError('Google sign-in cancelled.'); return; }
      ref.read(userProvider.notifier).setUser(user);
      await LocalStorageService.setOnboarded(false);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    } catch (_) {
      if (mounted) _showError('Google sign-up failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Logo + title ──────────────────────────
                Center(
                  child: Column(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 14),
                    const Text('Create account',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    const Text('Start your AI-powered study journey',
                        style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
                  ]),
                ),

                const SizedBox(height: 32),

                // ── Full Name (CustomTextField) ───────────
                const Text('Full name',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Enter your full name',
                  controller: _nameCtrl,
                  icon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 2) return 'Enter your full name';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

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

                // ── Password (CustomTextField) ────────────
                const Text('Password',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Min. 6 characters',
                  controller: _passCtrl,
                  icon: Icons.lock_outline,
                  obscureText: _obscurePass,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20, color: AppColors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Confirm Password (CustomTextField) ────
                const Text('Confirm password',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Re-enter your password',
                  controller: _confirmCtrl,
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20, color: AppColors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // ── Create Account (CustomButton) ─────────
                CustomButton(
                  label: 'Create Account',
                  onPressed: _signUp,
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

                // ── Google (CustomButton outlined) ────────
                CustomButton(
                  label: 'Continue with Google',
                  onPressed: _signUpWithGoogle,
                  isLoading: _loading,
                  outlined: true,
                ),

                const SizedBox(height: 32),

                // ── Sign In link ──────────────────────────
                Center(
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Sign In',
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