import 'package:flutter/material.dart';
import 'pages/todo_list_page.dart'; // Import halamannya dari folder pages

void main() {
  runApp(const MyApp());
}

// widget utama yang menampung seluruh aplikasi (statis)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // hilangkan banner debug jika diinginkan
      debugShowCheckedModeBanner: false,
      title: 'Todo List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // memanggil halaman utama dari file todo_list_page.dart
      home: const TodoListPage(), 
    );
  }
}
