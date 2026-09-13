import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../dashboard/main_dashboard.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainDashboard()),
      (route) => false,
    );
  }

  void _continueAsGuest() async {
    setState(() => _isLoading = true);
    final result = await ref.read(authServiceProvider).signInAnonymously();
    if (result != null && result.user != null) {
      if (mounted) _navigateToDashboard();
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to continue as guest. Please try again.')),
        );
      }
    }
  }

  void _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    // Email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await ref.read(authServiceProvider).signInWithEmail(email, password);
      } else {
        await ref.read(authServiceProvider).signUpWithEmail(email, password, name);
      }
      if (mounted) _navigateToDashboard();
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Authentication failed';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void _signInWithFacebook() async {
    setState(() => _isLoading = true);
    final result = await ref.read(authServiceProvider).signInWithFacebook();
    if (result != null && result.user != null) {
      await ref.read(authServiceProvider).syncUserProfile(result.user!);
      if (mounted) _navigateToDashboard();
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.charcoal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _isLogin ? 'Welcome Back' : 'Create Account',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isLogin 
                ? 'Sign in to your account to continue.' 
                : 'Join AnnaDaan and start sharing food.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            if (!_isLogin) ...[
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Full Name',
                ),
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                hintText: 'Email Address',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
                hintText: 'Password',
              ),
            ),
            if (_isLogin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleAuth,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin 
                    ? "Don't have an account? Sign Up" 
                    : "Already have an account? Login",
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 32),
            _SocialLoginButton(
              icon: Icons.facebook,
              label: 'Continue with Facebook',
              color: const Color(0xFF1877F2),
              textColor: Colors.white,
              onPressed: _isLoading ? null : _signInWithFacebook,
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : _continueAsGuest,
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          side: color == Colors.white ? BorderSide(color: Colors.grey[300]!) : null,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}
