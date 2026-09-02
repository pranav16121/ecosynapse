import 'package:flutter/material.dart';
import '../constants/dimens.dart';
import 'eco_button.dart';

class EcoLoadingState extends StatelessWidget {
  final String? message;
  const EcoLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: EcoSpacing.m),
            Text(message!),
          ],
        ],
      ),
    );
  }
}

class EcoSuccessState extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const EcoSuccessState({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EcoSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: EcoSpacing.l),
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: EcoSpacing.m),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: EcoSpacing.xl),
          EcoButton(label: buttonLabel, onPressed: onButtonPressed),
        ],
      ),
    );
  }
}

class EcoErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const EcoErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EcoSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: EcoSpacing.l),
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: EcoSpacing.m),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: EcoSpacing.xl),
          EcoButton(label: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }
}

class EcoEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const EcoEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EcoSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: EcoSpacing.m),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: EcoSpacing.s),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
