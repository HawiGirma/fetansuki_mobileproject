import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/core/utils/validators.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_state.dart';
import 'package:fetansuki_app/common/widgets/custom_button.dart';
import 'package:fetansuki_app/common/widgets/custom_text_field.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Authentication Failed')),
        );
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          CustomTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            hintText: 'Enter your password',
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
          
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login Button
          CustomButton(
            text: 'Login',
            onPressed: _submit,
            isLoading: authState.status == AuthStatus.loading,
          ),
          
          const SizedBox(height: 40),

          // Or Login with
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Or Login with', style: TextStyle(color: Colors.grey)),
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
            child: Image.asset('assets/images/google_icon.png'),
          ),
          const SizedBox(height: 50),

          // Register Now
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: Colors.black87),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Register Now',
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
