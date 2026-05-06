import 'package:flutter/material.dart';
import 'dart:ui';
import '../base/app_colors.dart';
import '../base/app_text_styles.dart';
import '../reusable/cc_buttons.dart';
import '../reusable/cc_text_fields.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = const AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Check your student email.'), 
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); 
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reset link'),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -50,
            child: _ColorBlob(color: AppColors.primary.withValues(alpha: 0.2), size: 200),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // The Hero Logo is now the primary visual focus
                    const Hero(tag: 'app_logo', child: _ElevatedLogo()),
                    const SizedBox(height: 48), // Increased spacing for better balance
                    
                    Text('Reset Password', style: AppTextStyles.h1),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your student email and we will send you a link to get back into your account.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    // Glassmorphic Card
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CCTextField(
                                  controller: _emailController,
                                  label: 'Student Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  validator: (v) => AuthService.validateStudentEmail(v),
                                ),
                                const SizedBox(height: 24),
                                CCPrimaryButton(
                                  label: 'SEND RESET LINK',
                                  onPressed: _handleReset,
                                  isLoading: _isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

// --- HELPER CLASSES ---

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
                decoration: TextDecoration.none,
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