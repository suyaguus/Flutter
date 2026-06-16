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
  List<Todo> todoList = [
    Todo(judul: 'Belajar Flutter'),
    Todo(judul: 'Membuat Aplikasi Todo'),
    Todo(judul: 'Test Aplikasi'),
    Todo(judul: 'Debug Aplikasi'),
    Todo(judul: 'Deploy Aplikasi'),
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
                    todoList.add(Todo(judul: _taskController.text));
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
            // checkbox interaktif
            leading: Checkbox(
              value: todoList[index].isSelesai, // ambil status dari data
              onChanged: (bool? nilaiBaru) {
                // saat dicentang/dihilangkan centangnya, perbarui status dan render ulang layar
                setState(() {
                  todoList[index].isSelesai = nilaiBaru!;
                });
              },
            ),

            // judul
            title: Text(
              todoList[index].judul,
              style: TextStyle(
                decoration: todoList[index].isSelesai
                    ? TextDecoration
                          .lineThrough // efekcoretan
                    : TextDecoration.none,
              ),
            ),

            // tombol hapus di sebelah kanan
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // saat tombol sampah ditekan, hapus item dari list
                setState(() {
                  todoList.removeAt(index);
                });
              },
            ),
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

// class untuk mencetak salinan untuk list todo
class Todo {
  String judul;
  bool isSelesai; // true jika sudah dicentang , false jika belum

  // constructor
  Todo({required this.judul, this.isSelesai = false});
}
