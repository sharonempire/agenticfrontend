import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../../core/utils/widgets/loading_button.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routePath = '/login';

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

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      context.go(DashboardScreen.routePath);
      return;
    }

    AppSnackbar.showError(
      context,
      authProvider.errorMessage ?? 'Unable to login. Please try again.',
    );
    authProvider.clearError();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth > 520 ? 420.0 : 520.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome back',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Login with your account credentials.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: _validatePassword,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 20),
                            LoadingButton(
                              label: 'Login',
                              isLoading: authProvider.isSubmitting,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: authProvider.isSubmitting
                                  ? null
                                  : () =>
                                        context.push(RegisterScreen.routePath),
                              child: const Text('Create a new account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Email is required';
    }
    const pattern = r'^[^@]+@[^@]+\.[^@]+$';
    if (!RegExp(pattern).hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Password is required';
    }
    if (text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
