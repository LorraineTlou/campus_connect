import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../base/app_colors.dart';
import '../base/app_text_styles.dart';
import '../services/auth_service.dart';
import '../reusable/campus_main_shell.dart';
import '../reusable/cc_text_fields.dart';
import '../reusable/cc_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = const AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      TextInput.finishAutofillContext();
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CampusMainShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _ColorBlob(color: AppColors.primary.withValues(alpha: 0.4), size: 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _ColorBlob(color: AppColors.secondary.withValues(alpha: 0.3), size: 250),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Hero(tag: 'app_logo', child: _ElevatedLogo()),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your university network',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 40),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: AutofillGroup(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  CCTextField(
                                    controller: _emailController,
                                    label: 'Student Email',
                                    hint: 'e.g., n02345678x@students.nust.ac.zw',
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    validator: (v) => AuthService.validateStudentEmail(v),
                                  ),
                                  const SizedBox(height: 16),
                                  CCPasswordField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    validator: (v) => v == null || v.isEmpty ? 'Enter your password' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: CCTextButton(
                                      label: 'Forgot Password?',
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  CCPrimaryButton(
                                    label: 'SIGN IN',
                                    onPressed: _handleLogin,
                                    isLoading: _isLoading,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        CCTextButton(
                          label: 'Sign Up',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (c) => const SignupScreen()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shared Helper Widgets (Place at the end of files)
class _ElevatedLogo extends StatelessWidget {
  const _ElevatedLogo();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: Text(
              'CAMPUS CONNECT',
              style: AppTextStyles.display.copyWith(
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _ColorBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}