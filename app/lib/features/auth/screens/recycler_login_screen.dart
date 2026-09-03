import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/widgets/eco_button.dart';
import '../../../core/widgets/eco_text_field.dart';

class RecyclerLoginScreen extends StatefulWidget {
  const RecyclerLoginScreen({super.key});

  @override
  State<RecyclerLoginScreen> createState() => _RecyclerLoginScreenState();
}

class _RecyclerLoginScreenState extends State<RecyclerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = 'demo.recycler@ecosynapse.app';
      _passwordController.text = 'EcoSynapse@2026';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recycler demo credentials populated.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthState>();
      if (authState.isLoading) return;

      try {
        await authState.loginForRole(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          expectedRole: UserRole.recycler,
        );
        if (mounted) {
          context.go('/recycler');
        }
      } catch (e) {
        if (mounted) {
          final msg = authState.errorMessage ?? e.toString().replaceAll('AuthException:', '').trim();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.recycling,
                  size: 56,
                  color: Colors.teal,
                ),
                const SizedBox(height: EcoSpacing.m),
                Text(
                  'Recycler Portal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: EcoSpacing.xs),
                Text(
                  'Processing portal for material recovery facilities and recycling plants.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: EcoSpacing.xl),
                EcoTextField(
                  label: 'Recycler Facility Email',
                  hintText: 'Enter facility email',
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
                    TextButton.icon(
                      onPressed: _fillDemoCredentials,
                      icon: const Icon(Icons.flash_on, size: 16),
                      label: const Text('Use Demo Account'),
                    ),
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                const SizedBox(height: EcoSpacing.l),
                EcoButton(
                  label: 'Sign In as Recycler',
                  onPressed: _onLogin,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: EcoSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(EcoSpacing.m),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(EcoRadius.medium),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'Need an account? Recycler facility accounts are provisioned by an administrator or facility operator.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
