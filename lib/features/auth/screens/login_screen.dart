import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/widgets/eco_button.dart';
import '../../../core/widgets/eco_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthState>().login(
          _emailController.text,
          _passwordController.text,
        );
        if (mounted) {
          context.go('/role-selector');
        }
      } catch (e) {
        // Handle error
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: EcoSpacing.xxl),
                Icon(
                  Icons.eco,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: EcoSpacing.l),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: EcoSpacing.s),
                Text(
                  'Sign in to continue your sustainable journey.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: EcoSpacing.xxl),
                EcoTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: EcoSpacing.m),
                EcoTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: EcoSpacing.s),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (val) =>
                                setState(() => _rememberMe = val ?? false),
                          ),
                        ),
                        const SizedBox(width: EcoSpacing.s),
                        const Text('Remember me'),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                const SizedBox(height: EcoSpacing.l),
                EcoButton(
                  label: 'Sign In',
                  onPressed: _onLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: EcoSpacing.l),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: const Text('Create Account'),
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
