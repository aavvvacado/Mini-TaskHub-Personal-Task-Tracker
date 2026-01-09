import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection_container.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Hero(
                        tag: 'auth_logo',
                        child:
                            Icon(
                              Icons.task_alt,
                              size: 80,
                              color: Theme.of(context).colorScheme.secondary,
                            ).animate().scale(
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            ),
                      ),
                      const Gap(24),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                      const Gap(48),
                      TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter email' : null,
                          )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideX(begin: -0.2, end: 0),
                      const Gap(16),
                      StatefulBuilder(
                        builder: (context, setState) {
                          bool isObscured = true;
                          return StatefulBuilder(
                            builder: (context, setStateInner) {
                               return TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                    onPressed: () {
                                      setStateInner(() {
                                        isObscured = !isObscured;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: isObscured,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter password';
                                  if (value.length < 8) return 'Password must be at least 8 characters';
                                  return null;
                                },
                              );
                            }
                          );
                        }
                      )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideX(begin: 0.2, end: 0),
                      const Gap(24),
                      FilledButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    AuthSignupRequested(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSecondary,
                        ),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator.adaptive()
                            : const Text('Sign Up'),
                      ).animate().fadeIn(delay: 400.ms).scale(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
