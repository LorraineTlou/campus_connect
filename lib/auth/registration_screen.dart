import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    // 1. Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Creating account for ${_nameController.text}...'), backgroundColor: Colors.blue),
      );

      // 2. Create the Auth Account (The Bouncer)
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Save the Profile Data (The Filing Cabinet)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'fullName': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': DateTime.now(),
          });

      // Guard for the async gap
      if (!mounted) return;

      // 4. Success and Navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully! Please log in.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Go back to the login screen

    } on FirebaseAuthException catch (e) {
      // Guard for the async gap during errors
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Premium soft grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Join your campus community',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Name Field
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name', 
                      prefixIcon: Icon(Icons.person_outline), 
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Student Email', 
                      prefixIcon: Icon(Icons.email_outlined), 
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Create Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isObscure = !_isObscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _isObscure,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password', 
                      prefixIcon: Icon(Icons.lock_reset), 
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Register Button
                  ElevatedButton(
                    onPressed: _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'SIGN UP', 
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Wrap prevents overflow on smaller screens
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: const Text('Login Here'),
                      ),
                    ],
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