import 'package:flutter/material.dart';
import '../constants/dimens.dart';

enum EcoButtonType { primary, secondary, text }

class EcoButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final EcoButtonType type;
  final bool isLoading;
  final bool fullWidth;

  const EcoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = EcoButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = type == EcoButtonType.primary
        ? ElevatedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 80, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          )
        : OutlinedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 80, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(EcoRadius.medium),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          );

    switch (type) {
      case EcoButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(label),
        );
      case EcoButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        );
      case EcoButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: Text(label),
        );
    }
  }
}
