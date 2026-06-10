import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/aura_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const HaFileApp());
}

class HaFileApp extends StatelessWidget {
  const HaFileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aethera Quantum Universe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
          surface: const Color(0xFF06060F),
        ),
        scaffoldBackgroundColor: const Color(0xFF06060F),
        useMaterial3: true,
      ),
      home: const AuraShell(),
    );
  }
}
