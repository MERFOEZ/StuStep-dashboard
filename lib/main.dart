import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/courses_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = AuthProvider();
            provider.toggleMockMode(false); // Start in Firebase Live Mode (disable mock)
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => CoursesProvider(),
        ),
      ],
      child: const StuStepAdminApp(),
    ),
  );
}

class StuStepAdminApp extends StatelessWidget {
  const StuStepAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Elegant Dark Theme Color Swatches
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF2DD4BF),
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2DD4BF),
        secondary: Color(0xFF6366F1),
        surface: Color(0xFF1E293B),
        background: Color(0xFF0B0F19),
        error: Colors.redAccent,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'system-ui', color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'system-ui', color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontFamily: 'system-ui', color: Color(0xDEFFFFFF)),
        bodyMedium: TextStyle(fontFamily: 'system-ui', color: Color(0x99FFFFFF)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
        thickness: 1,
      ),
    );

    return MaterialApp(
      title: 'STUSTEP Admin Dashboard',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Sync mock mode to CoursesProvider when mode changes
          final coursesProvider = Provider.of<CoursesProvider>(context, listen: false);
          if (coursesProvider.useMock != authProvider.useMock) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              coursesProvider.toggleMockMode(authProvider.useMock);
            });
          }

          if (authProvider.isAuthenticated) {
            return const DashboardShell();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
