import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/dimens.dart';
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
    if (_emailController.text.contains('@')) {
      setState(() => _isLoading = true);
      // Mock delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });
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
          title: 'Link Sent',
          message:
              'We have sent a password reset link to ${_emailController.text}. Please check your inbox.',
          buttonLabel: 'Back to Login',
          onButtonPressed: () => context.go('/login'),
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
                'Forgot Password',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: EcoSpacing.s),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: EcoSpacing.xl),
              EcoTextField(
                label: 'Email',
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
