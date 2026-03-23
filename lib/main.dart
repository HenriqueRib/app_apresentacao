import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/presentation_provider.dart';
import 'providers/resource_provider.dart';
import 'services/storage_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = await StorageService.getInstance();
  final isOnboardingCompleted = await storage.isOnboardingCompleted();
  
  runApp(MyApp(isOnboardingCompleted: isOnboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool isOnboardingCompleted;

  const MyApp({
    super.key,
    required this.isOnboardingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PresentationProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
      ],
      child: MaterialApp(
        title: 'Palestrante de Sucesso',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: isOnboardingCompleted 
            ? const HomeScreen() 
            : const OnboardingScreen(),
      ),
    );
  }
}
