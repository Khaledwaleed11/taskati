import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'splash/splash_screen.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox("myTask");
  await Hive.openBox("doneTask");
  await Hive.openBox("users");
  await Hive.openBox("session");

  await requestImagePermission();

  runApp(const MyApp());
}

Future<void> requestImagePermission() async {
  if (await Permission.photos.isDenied) {
    await Permission.photos.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,

      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'Taskati',

          themeMode: themeMode,

          theme: ThemeData(
            useMaterial3: true,

            brightness: Brightness.light,

            scaffoldBackgroundColor: const Color(0xFFF8F7FF),

            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurpleAccent,

              primary: Colors.deepPurpleAccent,

              brightness: Brightness.light,
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurpleAccent,

              foregroundColor: Colors.white,

              elevation: 0,

              centerTitle: true,
            ),

            cardTheme: CardThemeData(
              color: Colors.white,

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,

              fillColor: Colors.grey.shade100,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),

                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),

                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),

                borderSide: const BorderSide(
                  color: Colors.deepPurpleAccent,

                  width: 1.5,
                ),
              ),
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,

            brightness: Brightness.dark,

            scaffoldBackgroundColor: const Color(0xFF121212),

            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurpleAccent,

              primary: Colors.deepPurpleAccent,

              brightness: Brightness.dark,
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),

              foregroundColor: Colors.white,

              elevation: 0,

              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,

              fillColor: Color(0xFF2A2A2A),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),

                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),

                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),

                borderSide: BorderSide(
                  color: Colors.deepPurpleAccent,

                  width: 1.5,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}
