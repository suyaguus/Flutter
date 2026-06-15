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

// mmebuat statefulwidget
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

// halaman pertama aplikasi
class _TodoListPageState extends State<TodoListPage> {
  // const TodoListPage({super.key});

  // membuat tempat untuk menyimpan list sementara
  List<String> todoList = [
    'Belajar Flutter',
    'Membuat Aplikasi Todo',
    'Test Aplikasi',
    'Debug Aplikasi',
    'Deploy Aplikasi',
  ];

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
      // body: const Center(
      //   // Center digunakan untuk menengahkan widget di dalamnya
      //   child: Text('Belum ada List Hari ini!', style: TextStyle(fontSize: 20)),
      // ),

      // mengganti center dan text dengan listView.builder
      body: ListView.builder(
        // menghitung berapa jumlah list yang ada
        itemCount: todoList.length,

        // itemBuilder akan dipanggil berkali-kali sebanyak jumlah list yang ada (5 kali)
        itemBuilder: (context, index) {
          // ListTile adalah widget bawaan untuk baris daftar yang rapi
          return ListTile(
            // ikon kotak kosong dikiri
            leading: const Icon(Icons.check_box_outline_blank),
            // menampilkan teks sesuai urutan array
            title: Text(todoList[index]),
          );
        },
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
