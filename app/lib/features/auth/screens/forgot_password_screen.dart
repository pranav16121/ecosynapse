import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/widgets/eco_button.dart';
import '../../../core/widgets/eco_text_field.dart';
import '../../../core/widgets/eco_feedback_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSubmitted = false;
  bool _isLoading = false;

  void _onSubmit() async {
    final email = _emailController.text.trim();
    if (email.contains('@')) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthState>().resetPassword(email);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSubmitted = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return Scaffold(
        body: EcoSuccessState(
          title: 'Reset Link Sent',
          message:
              'We have sent a password reset email via Supabase Auth to ${_emailController.text}. Please check your inbox.',
          buttonLabel: 'Back to Auth Portal',
          onButtonPressed: () => context.go('/auth-portal'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset Password',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: EcoSpacing.s),
              Text(
                'Enter your account email address and Supabase Auth will send you a reset link.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: EcoSpacing.xl),
              EcoTextField(
                label: 'Email Address',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: EcoSpacing.xl),
              EcoButton(
                label: 'Send Reset Link',
                onPressed: _onSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
