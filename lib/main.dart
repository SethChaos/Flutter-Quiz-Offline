import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizz/services/database_service.dart';
import 'package:quizz/providers/quiz_provider.dart';
import 'package:quizz/providers/progress_provider.dart';
import 'package:quizz/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Check if data is already imported
  final prefs = await SharedPreferences.getInstance();
  final isDataImported = prefs.getBool('is_data_imported') ?? false;

  // Initialize database
  final dbService = DatabaseService.instance;
  await dbService.initDatabase();

  if (!isDataImported) {
    await dbService.importQuestionsData();
    await prefs.setBool('is_data_imported', true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aviation Quiz',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1A237E), // Deep blue for aviation feel
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: const Color(0xFFFF8F00), // Amber accent
            brightness: Brightness.light,
          ),
          fontFamily: 'Poppins',
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF0D47A1),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: const Color(0xFFFFB300),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
