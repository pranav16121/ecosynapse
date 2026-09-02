import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_button.dart';
import '../../../core/widgets/eco_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedCommunityId;
  bool _isLoading = false;

  void _onSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }
      if (_selectedCommunityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a community')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        await context.read<AuthState>().signUp(
          fullName: _nameController.text,
          email: _emailController.text,
          communityId: _selectedCommunityId!,
        );
        if (mounted) {
          context.go('/role-selector');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'Create Account',
                  key: const Key('signup_title'),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: EcoSpacing.s),
                Text(
                  'Join the movement for a greener future.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: EcoSpacing.xl),
                EcoTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  controller: _nameController,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Enter your name' : null,
                ),
                const SizedBox(height: EcoSpacing.m),
                EcoTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value?.contains('@') ?? false
                      ? null
                      : 'Enter valid email',
                ),
                const SizedBox(height: EcoSpacing.m),
                Text(
                  'Community',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: EcoSpacing.s),
                DropdownButtonFormField<String>(
                  value: _selectedCommunityId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(EcoRadius.medium),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  hint: const Text('Select your community'),
                  items: MockData.communities.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCommunityId = val),
                  validator: (val) =>
                      val == null ? 'Please select a community' : null,
                ),
                const SizedBox(height: EcoSpacing.m),
                EcoTextField(
                  label: 'Password',
                  hintText: 'Create a password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) =>
                      (value?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: EcoSpacing.m),
                EcoTextField(
                  label: 'Confirm Password',
                  hintText: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: EcoSpacing.l),
                EcoButton(
                  label: 'Create Account',
                  onPressed: _onSignup,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: EcoSpacing.l),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Sign In'),
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
