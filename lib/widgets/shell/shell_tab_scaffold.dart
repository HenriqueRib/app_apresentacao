import 'package:flutter/material.dart';
import 'gradient_background.dart';

class ShellTabScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const ShellTabScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          actions: actions,
          bottom: bottom,
        ),
        body: body,
      ),
    );
  }
}
