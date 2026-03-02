import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../../core/utils/widgets/loading_button.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routePath = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      AppSnackbar.showSuccess(context, 'Account created successfully.');
      context.go(DashboardScreen.routePath);
      return;
    }

    AppSnackbar.showError(
      context,
      authProvider.errorMessage ?? 'Unable to register. Please try again.',
    );
    authProvider.clearError();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Get started',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create an account to continue.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              textInputAction: TextInputAction.next,
                              validator: _validateName,
                            ),
                            const SizedBox(height: 14),
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
                              textInputAction: TextInputAction.next,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: _validateConfirmPassword,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 20),
                            LoadingButton(
                              label: 'Register',
                              isLoading: authProvider.isSubmitting,
                              onPressed: _submit,
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

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Name is required';
    }
    if (text.length < 2) {
      return 'Enter a valid name';
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value.trim() != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }
}
