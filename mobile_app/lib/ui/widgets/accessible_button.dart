import 'package:flutter/material.dart';

class AccessibleButton extends StatelessWidget {
  final String label;
  final String? accessibilityLabel;
  final String? accessibilityHint;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AccessibleButton({
    Key? key,
    required this.label,
    this.accessibilityLabel,
    this.accessibilityHint,
    required this.onPressed,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Explicit Semantics element for screen readers (VoiceOver/TalkBack)
    return Semantics(
      button: true,
      label: accessibilityLabel ?? label,
      hint: accessibilityHint,
      child: ConstrainedBox(
        // Adheres to 48x48 dp minimum tap targets (WCAG 2.1 rule)
        constraints: const BoxConstraints(
          minWidth: 88,
          minHeight: 48,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: isPrimary
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: onPressed,
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              : OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: onPressed,
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
        ),
      ),
    );
  }
}
