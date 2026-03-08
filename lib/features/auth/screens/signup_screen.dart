import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUpWithEmail(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
    );
    if (ok && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0A14), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                IconButton(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.fireGradient.createShader(b),
                  child: const Text(
                    'Create\nAccount ❤️‍🔥',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Start your intimate journey today',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary)),
                const SizedBox(height: 48),
                _FieldBlock('Your Name', Icons.person_outline, _nameCtrl,
                    'Enter your first name'),
                const SizedBox(height: 20),
                _FieldBlock('Email', Icons.email_outlined, _emailCtrl,
                    'you@example.com',
                    type: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _PasswordBlock(_passCtrl, _obscure,
                    () => setState(() => _obscure = !_obscure)),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.error.withAlpha(80)),
                    ),
                    child: Text(auth.errorMessage!,
                        style: const TextStyle(
                            color: AppColors.error,
                            fontFamily: 'Inter',
                            fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient:
                            loading ? null : AppColors.primaryGradient,
                        color: loading ? AppColors.surfaceElevated : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Create Account',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Inter')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Already have an account? ',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter')),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: const Text('Sign In',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType? type;
  const _FieldBlock(this.label, this.icon, this.ctrl, this.hint, {this.type});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textHint)),
      ),
    ]);
  }
}

class _PasswordBlock extends StatelessWidget {
  final TextEditingController ctrl;
  final bool obscure;
  final VoidCallback onToggle;
  const _PasswordBlock(this.ctrl, this.obscure, this.onToggle);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Password',
          style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: '••••••••',
          prefixIcon:
              const Icon(Icons.lock_outline, color: AppColors.textHint),
          suffixIcon: IconButton(
            icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textHint),
            onPressed: onToggle,
          ),
        ),
      ),
    ]);
  }
}
