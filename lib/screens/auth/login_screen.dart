import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/screens/main_screen.dart';

import '../../core/constants/app_strings.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../widgets/auth_widgets.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';
import 'email_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else if (state is AuthEmailVerificationRequired) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => EmailVerificationScreen(email: state.email),
            ),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppStrings.login.tr(),
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      controller: _emailController,
                      labelKey: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'required_field'.tr();
                        }
                        if (!value!.contains('@')) {
                          return 'invalid_email'.tr();
                        }
                        return null;
                      },
                    ),
                    AuthTextField(
                      controller: _passwordController,
                      labelKey: AppStrings.password,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'required_field'.tr();
                        }
                        if (value!.length < 6) {
                          return 'short_password'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ResetPasswordScreen(),
                            ),
                          );
                        },
                        child: Text('forgot_password'.tr()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return AuthButton(
                          labelKey: AppStrings.login,
                          onPressed: _handleLogin,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text('Dont have an account? Register'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
