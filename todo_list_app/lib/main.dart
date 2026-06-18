import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/todo_list_page.dart';

// Variabel Global (Sakelar Pusat) untuk menyimpan status tema
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Wajib ditambahkan jika fungsi main() memanggil async (seperti SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // Baca pengaturan tema yang tersimpan di memori HP
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;

  // Setel nilai awal tema sesuai data dari memori
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder akan "mendengarkan" perubahan pada themeNotifier.
    // Jika tombol di halaman pengaturan ditekan, seluruh aplikasi otomatis tergambar ulang.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo List App',
          // --- PENGATURAN TEMA TERANG ---
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          // --- PENGATURAN TEMA GELAP ---
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          // --- TEMA SAAT INI (mengikuti sakelar) ---
          themeMode: currentMode,

          home: const TodoListPage(),
        );
      },
    );
  }
}
