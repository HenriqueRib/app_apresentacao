import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.shellBackgroundGradient,
      ),
      child: child,
    );
  }
}
