import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/presentation_provider.dart';
import 'providers/resource_provider.dart';
import 'providers/speech_provider.dart';
import 'providers/meeting_hub_provider.dart';
import 'providers/study_studio_provider.dart';
import 'providers/timer_pro_provider.dart';
import 'providers/oratory_guide_provider.dart';
import 'providers/assentinel_provider.dart';
import 'providers/parte_provider.dart';
import 'providers/discurso_admin_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PresentationProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
        ChangeNotifierProvider(create: (_) => MeetingHubProvider()),
        ChangeNotifierProvider(create: (_) => StudyStudioProvider()),
        ChangeNotifierProvider(create: (_) => TimerProProvider()),
        ChangeNotifierProvider(create: (_) => OratoryGuideProvider()),
        ChangeNotifierProvider(create: (_) => AssentinelProvider()),
        ChangeNotifierProvider(create: (_) => ParteProvider()),
        ChangeNotifierProvider(create: (_) => DiscursoAdminProvider()),
      ],
      child: MaterialApp(
        title: 'Poder de Convencer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}

