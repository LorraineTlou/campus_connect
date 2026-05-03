import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_screen.dart';
import 'forgot_password_screen.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../reusable/cc_buttons.dart';
import '../reusable/cc_text_fields.dart';
import '../reusable/campus_main_shell.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          // ✅ Navigate to CampusMainShell after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CampusMainShell()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Authentication failed'),
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenInsets,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo or Icon
                const Center(
                  child: Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Campus Connect',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to stay connected with your campus',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),

                CCTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your university email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                CCPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  textInputAction: TextInputAction.done,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: CCTextButton(
                    label: 'Forgot Password?',
                    onPressed: () {
                      // ✅ Navigate to Forgot Password screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                CCPrimaryButton(
                  label: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    CCTextButton(
                      label: 'Sign Up',
                      onPressed: () {
                        // ✅ Navigate to Registration screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}