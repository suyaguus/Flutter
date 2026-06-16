import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Todo> todoList = [];

  // controller untuk mengambil teks yang di inputkan
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  // Fungsi untuk menyimpan data ke memori
  Future<void> _simpanData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listString = todoList
        .map((todo) => jsonEncode(todo.toMap()))
        .toList();
    await prefs.setStringList('data_todo', listString);
  }

  Future<void> _muatData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? listString = prefs.getStringList('data_todo');

    if (listString != null) {
      setState(() {
        todoList = listString
            .map((item) => Todo.fromMap(jsonDecode(item)))
            .toList();
      });
    }
  }

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
                    _simpanData();
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

      // body.
      body: todoList.isEmpty
          // JIKA KOSONG: Tampilkan Empty State
          ? Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Pusatkan secara vertikal
                children: const [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 16,
                  ), // Memberi jarak kosong antara ikon dan teks
                  Text(
                    'Semua Tugas Sudah Selesai!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          // JIKA ADA ISINYA: Tampilkan ListView
          : ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                // Membungkus ListTile dengan Card
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ), // Jarak luar kartu
                  elevation: 2, // Efek bayangan (shadow) agar terlihat melayang
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ), // Membuat ujung kartu sedikit membulat
                  child: ListTile(
                    leading: Checkbox(
                      value: todoList[index].isSelesai,
                      onChanged: (bool? nilaiBaru) {
                        setState(() {
                          todoList[index].isSelesai = nilaiBaru!;
                          _simpanData();
                        });
                      },
                    ),
                    title: Text(
                      todoList[index].judul,
                      style: TextStyle(
                        decoration: todoList[index].isSelesai
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      // Simpan judulnya dulu sebelum dihapus untuk ditampilkan di pesan
                      onPressed: () {
                        String judulDihapus = todoList[index].judul;
                        setState(() {
                          todoList.removeAt(index);
                          _simpanData();
                        });
                        // Memunculkan Snackbar (Notifikasi bawah)
                        ScaffoldMessenger.of(
                          context,
                        ).clearSnackBars(); // Bersihkan pesan lama jika ada
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'List "$judulDihapus" telah dihapus!',
                            ),
                            duration: const Duration(
                              seconds: 2,
                            ), // Lama pesan muncul
                            behavior: SnackBarBehavior
                                .floating, //  Pesannya sedikit melayang
                          ),
                        );
                      },
                    ),
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

  Map<String, dynamic> toMap() {
    return {'judul': judul, 'isSelesai': isSelesai};
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(judul: map['judul'], isSelesai: map['isSelesai']);
  }
}
