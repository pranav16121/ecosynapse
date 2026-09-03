import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_button.dart';
import '../../../core/widgets/eco_text_field.dart';

class ResidentSignupScreen extends StatefulWidget {
  const ResidentSignupScreen({super.key});

  @override
  State<ResidentSignupScreen> createState() => _ResidentSignupScreenState();
}

class _ResidentSignupScreenState extends State<ResidentSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _flatNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedCommunityId = '1';

  void _onSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      final authState = context.read<AuthState>();
      if (authState.isLoading) return; // Prevent duplicate button presses

      try {
        await authState.signUp(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          communityId: _selectedCommunityId ?? '1',
          password: _passwordController.text,
          flatNo: _flatNoController.text.trim(),
        );
        if (mounted) {
          context.go('/resident');
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
                Text(
                  'Create Resident Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: EcoSpacing.xs),
                Text(
                  'Join your community for a greener, sustainable future.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: EcoSpacing.xl),
                EcoTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  controller: _nameController,
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Enter your name' : null,
                ),
                const SizedBox(height: EcoSpacing.m),
                EcoTextField(
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value?.contains('@') ?? false
                      ? null
                      : 'Enter a valid email address',
                ),
                const SizedBox(height: EcoSpacing.m),
                EcoTextField(
                  label: 'Flat / Apartment Number',
                  hintText: 'e.g. Tower A - 402',
                  controller: _flatNoController,
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Enter your flat number' : null,
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
                ),
                const SizedBox(height: EcoSpacing.m),
                EcoTextField(
                  label: 'Password',
                  hintText: 'Create a password (min 6 characters)',
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
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Confirm your password' : null,
                ),
                const SizedBox(height: EcoSpacing.l),
                EcoButton(
                  label: 'Create Resident Account',
                  onPressed: _onSignup,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: EcoSpacing.l),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Already have a Resident account?'),
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
