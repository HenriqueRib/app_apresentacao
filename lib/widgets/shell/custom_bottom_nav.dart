import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glow;

  static const _destinations = [
    _NavItem(Icons.home_outlined, Icons.home, 'Início'),
    _NavItem(Icons.menu_book_outlined, Icons.menu_book, '53 Lições'),
    _NavItem(Icons.insights_outlined, Icons.insights, 'Progresso'),
    _NavItem(Icons.auto_stories_outlined, Icons.auto_stories, 'Criar Esboço'),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.shellNavBackground,
        border: Border(
          top: BorderSide(
            color: Color(0xFF1A2535),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(_destinations.length, (index) {
              final item = _destinations[index];
              final isSelected = index == widget.selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onDestinationSelected(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _glow,
                        builder: (context, child) {
                          return Container(
                            width: 44,
                            height: 44,
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: AppTheme.shellAccentTeal
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.shellAccentTeal
                                            .withValues(alpha: _glow.value),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  )
                                : null,
                            child: child,
                          );
                        },
                        child: Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          color: isSelected
                              ? AppTheme.shellAccentTeal
                              : AppTheme.shellTextSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? AppTheme.shellAccentTeal
                              : AppTheme.shellTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}
