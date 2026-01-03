import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fetansuki_app/core/utils/validators.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_state.dart';
import 'package:fetansuki_app/common/widgets/custom_button.dart';
import 'package:fetansuki_app/common/widgets/custom_text_field.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).register(
            _usernameController.text,
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Registration Failed')),
        );
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Username Field
          CustomTextField(
            controller: _usernameController,
            hintText: 'Username',
            validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
          ),
          const SizedBox(height: 20),

          // Email Field
          CustomTextField(
            controller: _emailController,
            hintText: 'Email',
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            hintText: 'Password',
            validator: Validators.validatePassword,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          // Confirm Password Field
          CustomTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm password',
            validator: _validateConfirmPassword,
            obscureText: !_isConfirmPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 30),

          // Register Button
          CustomButton(
            text: 'Sign Up',
            onPressed: _submit,
            isLoading: authState.status == AuthStatus.loading,
          ),
          
          const SizedBox(height: 40),

          // Or Register with
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Or Register with', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
            ],
          ),
          const SizedBox(height: 30),

          // Google Login Button (Placeholder)
          Container(
            height: 60,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset("assets/images/google_icon.png"),
          ),
          const SizedBox(height: 50),

          // Login Now
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(color: Colors.black87),
              ),
              GestureDetector(
                onTap: () {
                    // Navigate to Login Page
                    context.go('/login');
                },
                child: const Text(
                  'Login Now',
                  style: TextStyle(
                    color: Color(0xFF14B8A6), // Teal/Cyan
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
