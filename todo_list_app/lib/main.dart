import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/todo_list_page.dart';

// 1. Sakelar Pusat
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<String> languageNotifier = ValueNotifier(
  'id',
); // 'id' = Indo, 'en' = English

// 2. FUNGSI PINTAS AJAIB UNTUK TERJEMAHAN
String tr(String idText, String enText) {
  return languageNotifier.value == 'id' ? idText : enText;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Baca Tema
  final isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // Baca Bahasa
  final savedLang = prefs.getString('language') ?? 'id';
  languageNotifier.value = savedLang;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita tumpuk 2 "Pendengar" agar aplikasi langsung merespon saat tema/bahasa diubah
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (_, String currentLang, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Todo List App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                  surface: const Color.fromARGB(255, 33, 40, 48),
                ),
                scaffoldBackgroundColor: const Color.fromARGB(255, 33, 40, 48),
                useMaterial3: true,
              ),
              themeMode: currentMode,
              home: const TodoListPage(),
            );
          },
        );
      },
    );
  }
}
