import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/app_colors.dart';
import '../base/app_text_styles.dart';
import '../models/user_model.dart';
import '../reusable/cc_buttons.dart';
import '../reusable/cc_text_fields.dart';
import '../services/auth_service.dart';
import '../reusable/campus_main_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'), 
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = const AuthService();
      final userCredential = await authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null && mounted) {
        final newUser = UserModel(
          uid: user.uid,
          name: _nameController.text.trim(),
          username: _nameController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''),
          email: _emailController.text.trim().toLowerCase(),
          createdAt: DateTime.now(),
        );
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUser.toMap());
        
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const CampusMainShell()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed'), 
            backgroundColor: AppColors.danger,
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
          // Background Depth Blobs
          Positioned(
            top: -50, 
            left: -50, 
            child: _ColorBlob(color: AppColors.primary.withValues(alpha: 0.3), size: 250),
          ),
          Positioned(
            bottom: -100, 
            right: -50, 
            child: _ColorBlob(color: AppColors.secondary.withValues(alpha: 0.2), size: 300),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Hero(tag: 'app_logo', child: _ElevatedLogo()),
                    const SizedBox(height: 12),
                    Text(
                      'Join your campus community',
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
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5), 
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CCTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                                ),
                                const SizedBox(height: 16),
                                CCTextField(
                                  controller: _emailController,
                                  label: 'Student Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  validator: (v) => AuthService.validateStudentEmail(v),
                                ),
                                const SizedBox(height: 16),
                                CCPasswordField(controller: _passwordController, label: 'Password'),
                                const SizedBox(height: 16),
                                CCPasswordField(controller: _confirmPasswordController, label: 'Confirm Password'),
                                const SizedBox(height: 24),
                                CCPrimaryButton(
                                  label: 'CREATE ACCOUNT', 
                                  onPressed: _handleSignUp, 
                                  isLoading: _isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Footer: Only "Sign In" is a button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        CCTextButton(
                          label: 'Sign In', 
                          onPressed: () => Navigator.pop(context),
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

// --- HELPER CLASSES DEFINED AT BOTTOM TO PREVENT ERRORS ---

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
        // Material fix for green underlines
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