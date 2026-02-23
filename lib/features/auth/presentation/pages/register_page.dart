import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/ds_button.dart';
import '../../../../core/presentation/widgets/ds_text_field.dart';
import '../../../../core/presentation/widgets/ds_feedback_panel.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onRegisterPressed() {
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.background, Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                // If it was pushed on top of login, this will pop back.
                // The main GoRouter redirect will simultaneously handle sending to /home
                Navigator.of(context).pop();
              } else if (state is AuthRegistered) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogCtx) => AlertDialog(
                    backgroundColor: AppTheme.cardColor,
                    title: const Text(
                      'Account Created',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      'Your account was created successfully. Would you like to log in now?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogCtx).pop();
                                context.read<AuthBloc>().add(
                                  AuthLoginRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('Log In Now'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogCtx).pop();
                                Navigator.of(
                                  context,
                                ).pop(); // Go back to login screen
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildRegisterForm(context, state),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, AuthState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          if (state is AuthError) ...[
            DSFeedbackPanel(message: state.message),
            const SizedBox(height: 16),
          ],
          DSTextField(
            label: 'Full Name',
            hint: 'John Doe',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          DSTextField(
            label: 'Email Address',
            hint: 'your@email.com',
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          DSTextField(
            label: 'Security Password',
            hint: '••••••••',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: 32),
          DSButton(
            label: 'Create Account',
            isLoading: state is AuthLoading,
            onPressed: _onRegisterPressed,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
