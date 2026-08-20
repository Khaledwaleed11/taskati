import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'auth/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox("myTask");
  await Hive.openBox("doneTask");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
        ),

        cardTheme: const CardThemeData(
          color: Colors.white,
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}