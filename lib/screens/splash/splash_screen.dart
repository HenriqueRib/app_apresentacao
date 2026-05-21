import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../services/characteristics_service.dart';
import '../home_screen_new.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  double _loadingProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // 2. Mock a premium loading bar progress
    _startLoadingBar();

    // 3. Initialize background processes and navigate
    _initializeApp();
  }

  void _startLoadingBar() {
    const totalSteps = 100;
    const duration = Duration(milliseconds: 2500);
    final stepTime = duration.inMilliseconds ~/ totalSteps;

    _progressTimer = Timer.periodic(Duration(milliseconds: stepTime), (timer) {
      if (mounted) {
        setState(() {
          if (_loadingProgress < 1.0) {
            _loadingProgress += 0.01;
          } else {
            _progressTimer?.cancel();
          }
        });
      }
    });
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    // Initialize SharedPreferences & load static data
    final storage = await StorageService.getInstance();
    final isOnboardingCompleted = await storage.isOnboardingCompleted();
    await CharacteristicsService.instance.loadData();

    // Ensure splash stays for at least 3 seconds for premium animation pacing
    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(milliseconds: 3000) - elapsed;
    
    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return isOnboardingCompleted 
                ? const HomeScreenNew() 
                : const OnboardingScreen();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19), // Royal Deep Indigo Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1530), // Deep blue
              Color(0xFF070B19), // Dark midnight indigo
              Color(0xFF03050B), // Near black base
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background glowing accents
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.05),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
            
            // Central Content
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing app icon container
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Elegant fallback if image fails loading
                              return Container(
                                width: 140,
                                height: 140,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF101B3B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mic_none_outlined,
                                  size: 70,
                                  color: Color(0xFFFFD700),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // App Name
                      Text(
                        'Palestrante de Sucesso',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFFFD700), // Pure gold color accent
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Tagline
                      Text(
                        'Transforme seu mindset, conquiste sua audiência',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.4,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Loading Indicator and Signature
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  // Elegant Golden Linear Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 4,
                      width: 160,
                      child: LinearProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Premium Subtext Signature
                  Text(
                    'MÉTODO SHINYASHIKI',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
