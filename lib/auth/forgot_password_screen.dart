import 'package:flutter/material.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _authService.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset link sent! Check your email.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Go back to login
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send reset link'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withOpacity(0.06), Colors.white]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Center(child: Icon(Icons.lock_reset_rounded, size: 80, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                      children: [
                        const TextSpan(text: 'Campus\n', style: TextStyle(color: Colors.black87)),
                        TextSpan(text: 'Connect', style: TextStyle(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Reset Password', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 8),
                  Text('Enter your student email and we will send you a link to reset your password.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))]),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        CCTextField(controller: _emailController, label: 'Student Email', hint: 'Enter your university email', prefixIcon: const Icon(Icons.email_outlined), keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.done, validator: (value) => AuthService.validateStudentEmail(value, emptyMessage: 'Email is required', invalidMessage: 'Enter a valid @students.nust.ac.zw email')),
                        const SizedBox(height: 24),
                        CCPrimaryButton(label: 'SEND RESET LINK', onPressed: _handleReset, isLoading: _isLoading),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}