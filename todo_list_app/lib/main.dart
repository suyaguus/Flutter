import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// widget utama yang menampung seluruh aplikasi (statis)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // judul
      title: 'Todo List App',
      theme: ThemeData(
        // skema warna
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // menentukan halaman pertama mana yang akan di panggil
      home: const TodoListPage(),
    );
  }
}

// halaman pertama aplikasi
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold adalah struktur dasar halaman (layar putih kosong)
    return Scaffold(
      // appbar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Todo List'),
      ),
      // body
      body: const Center(
        // Center digunakan untuk menengahkan widget di dalamnya
        child: Text('Belum ada List Hari ini!', style: TextStyle(fontSize: 20)),
      ),
      // floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // aksi ketika tombol ditekan (via terminal)
          print("Tombol Tambah Ditekan!");
        },
        tooltip: 'Tambah List',
        // menampilkan icon plus
        child: const Icon(Icons.add),
      ),
    );
  }
}
