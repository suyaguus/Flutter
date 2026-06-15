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

// membuat todo list dinamis
class _TodoListPageState extends State<TodoListPage> {
  // membuat tempat meyimpan data list sementara
  List<String> todoList = [
    'Belajar Flutter',
    'Membuat Aplikasi Todo',
    'Test Aplikasi',
    'Debug Aplikasi',
    'Deploy Aplikasi',
  ];

  // controller untuk mengambil teks yang di inputkan
  final TextEditingController _taskController = TextEditingController();

  // fungsi untuk memunculkan popup dialog
  void _tambahList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah List Baru'),
          content: TextField(
            // hubungkan controller ke text field
            controller: _taskController,
            decoration: const InputDecoration(hintText: 'Masukkan List Baru: '),
          ),
          actions: [
            // tombol batal
            TextButton(
              // Perintah untuk menutup Dialog
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),

            // tombol simpan
            TextButton(
              onPressed: () {
                // Mengecek agar tidak menyimpan tugas kosong
                if (_taskController.text.isNotEmpty) {
                  // setState() sangat penting! Ini memberitahu Flutter bahwa
                  // ada data yang berubah dan layar harus digambar ulang.
                  setState(() {
                    // Tambahkan teks ke array list
                    todoList.add(_taskController.text);
                  });
                  // Bersihkan inputan untuk pemakaian berikutnya
                  _taskController.clear();
                  // Tutup Dialog
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // fungsi untuk menampilkan isi
  @override
  Widget build(BuildContext context) {
    // menggunakan sccafold
    return Scaffold(
      // appbar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Todo List'),
      ),

      // body
      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_box_outline_blank),
            title: Text(todoList[index]),
          );
        },
      ),

      // button action
      floatingActionButton: FloatingActionButton(
        // panggil fungsi _tambahList() ketika ditekan
        onPressed: _tambahList,
        tooltip: 'Tambah List',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// halaman pertama aplikasi
// class _TodoListPageState extends State<TodoListPage> {
//   // const TodoListPage({super.key});

//   // membuat tempat untuk menyimpan list sementara
//   List<String> todoList = [
//     'Belajar Flutter',
//     'Membuat Aplikasi Todo',
//     'Test Aplikasi',
//     'Debug Aplikasi',
//     'Deploy Aplikasi',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     // Scaffold adalah struktur dasar halaman (layar putih kosong)
//     return Scaffold(
//       // appbar
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('My Todo List'),
//       ),

//       // body
//       // body: const Center(
//       //   // Center digunakan untuk menengahkan widget di dalamnya
//       //   child: Text('Belum ada List Hari ini!', style: TextStyle(fontSize: 20)),
//       // ),

//       // mengganti center dan text dengan listView.builder
//       body: ListView.builder(
//         // menghitung berapa jumlah list yang ada
//         itemCount: todoList.length,

//         // itemBuilder akan dipanggil berkali-kali sebanyak jumlah list yang ada (5 kali)
//         itemBuilder: (context, index) {
//           // ListTile adalah widget bawaan untuk baris daftar yang rapi
//           return ListTile(
//             // ikon kotak kosong dikiri
//             leading: const Icon(Icons.check_box_outline_blank),
//             // menampilkan teks sesuai dengan urutan array
//             title: Text(todoList[index]),
//           );
//         },
//       ),

//       // floating button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // aksi ketika tombol ditekan (via terminal)
//           print("Tombol Tambah Ditekan!");
//         },
//         tooltip: 'Tambah List',
//         // menampilkan icon plus
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
