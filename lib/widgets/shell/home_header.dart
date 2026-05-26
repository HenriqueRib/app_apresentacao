import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.shellTextPrimary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.shellTextPrimary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificações em breve.'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Vamos evoluir sua\ncomunicação?',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 26,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Método Shinyashiki + 53 Características',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
