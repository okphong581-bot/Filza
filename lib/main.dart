import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/file_manager_screen.dart';

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
      title: 'Ha Floating Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
          surface: const Color(0xFF0D0D1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        useMaterial3: true,
      ),
      home: const FileManagerScreen(),
    );
  }
}
