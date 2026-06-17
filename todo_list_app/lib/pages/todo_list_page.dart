import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart'; // Import class Todo dari folder models

// membuat statefulwidget
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // (Potongan kode di bawah ini sengaja disingkat agar Anda tinggal copy-paste/cut dari file lama)
  List<Todo> todoList = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  // simpan list
  Future<void> _simpanData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listString = todoList
        .map((todo) => jsonEncode(todo.toMap()))
        .toList();
    await prefs.setStringList('data_todo', listString);
  }

  // baca list
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

  // tambah list
  void _tambahList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah List Baru'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: 'Masukkan List Baru: '),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  setState(() {
                    todoList.add(Todo(judul: _taskController.text));
                    _simpanData();
                  });
                  _taskController.clear();
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

  // edit list
  // Fungsi untuk memunculkan popup dialog Edit
  void _editList(int index) {
    // Isi TextField dengan judul tugas yang sedang ditekan
    _taskController.text = todoList[index].judul;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Tugas'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: 'Ubah teks tugas:'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _taskController.clear(); // Bersihkan memori controller
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  setState(() {
                    // Update judul list pada index yang dipilih
                    todoList[index].judul = _taskController.text;
                    _simpanData(); // Simpan perubahan ke memori hp
                  });
                  _taskController.clear(); // Bersihkan memori
                  Navigator.of(context).pop(); // Tutup dialog
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Todo List'),
      ),
      body: todoList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Semua Tugas Sudah Selesai!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                      onPressed: () {
                        String judulDihapus = todoList[index].judul;
                        setState(() {
                          todoList.removeAt(index);
                          _simpanData();
                        });
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'List "$judulDihapus" telah dihapus!',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahList,
        tooltip: 'Tambah List',
        child: const Icon(Icons.add),
      ),
    );
  }
}
