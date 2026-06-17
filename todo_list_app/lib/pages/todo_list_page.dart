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

  // untuk filter dan shorting
  String filterPrioritas =
      'Semua'; // Opsi: Semua, Penting, Mendesak, Tidak Mendesak
  bool sortDeadlineTerdekat = false;

  // Fungsi "Penyaring Cerdas" yang menggabungkan Filter & Sorting
  List<Todo> get listYangDitampilkan {
    // 1. Saring berdasarkan prioritas
    List<Todo> hasil = todoList.where((todo) {
      if (filterPrioritas == 'Semua') return true;
      return todo.prioritas == filterPrioritas;
    }).toList();

    // 2. Urutkan berdasarkan tanggal terdekat
    if (sortDeadlineTerdekat) {
      hasil.sort((a, b) {
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1; // Yang kosong ditaruh paling bawah
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
    }
    return hasil;
  }

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

  // Fungsi tambah list baru
  void _tambahList() {
    String prioritasDipilih = "Tidak Mendesak";
    DateTime? tanggalDipilih;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Memungkinkan popup mengubah tampilannya sendiri
          builder: (context, setStatePopup) {
            return AlertDialog(
              title: const Text('Tambah List Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan List Baru',
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Dropdown Prioritas
                  DropdownButtonFormField<String>(
                    value: prioritasDipilih,
                    decoration: const InputDecoration(labelText: 'Prioritas'),
                    items: ['Penting', 'Mendesak', 'Tidak Mendesak'].map((
                      String val,
                    ) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (val) {
                      setStatePopup(() {
                        prioritasDipilih = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // Baris Pemilihan Tanggal
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tanggalDipilih == null
                              ? 'Belum ada Tenggat'
                              : 'Tenggat: ${tanggalDipilih!.day}/${tanggalDipilih!.month}/${tanggalDipilih!.year}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () async {
                          // Memunculkan kalender bawaan Android/Web
                          DateTime? tgl = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (tgl != null) {
                            setStatePopup(() {
                              tanggalDipilih = tgl;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _taskController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      setState(() {
                        // Tambahkan data lengkap ke list
                        todoList.add(
                          Todo(
                            judul: _taskController.text,
                            prioritas: prioritasDipilih,
                            deadline: tanggalDipilih,
                          ),
                        );
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
      },
    );
  }

  // Fungsi edit list
  void _editList(int index) {
    _taskController.text = todoList[index].judul;
    String prioritasDipilih = todoList[index].prioritas;
    DateTime? tanggalDipilih = todoList[index].deadline;

    // Mencegah error jika membaca data lama di memori
    if (!['Penting', 'Mendesak', 'Tidak Mendesak'].contains(prioritasDipilih)) {
      prioritasDipilih = 'Tidak Mendesak'; // Ubah paksa ke nilai default baru
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return AlertDialog(
              title: const Text('Edit Tugas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Ubah teks tugas:',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: prioritasDipilih,
                    decoration: const InputDecoration(labelText: 'Prioritas'),
                    items: ['Penting', 'Mendesak', 'Tidak Mendesak'].map((
                      String val,
                    ) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (val) {
                      setStatePopup(() {
                        prioritasDipilih = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tanggalDipilih == null
                              ? 'Belum ada Tenggat'
                              : 'Tenggat: ${tanggalDipilih!.day}/${tanggalDipilih!.month}/${tanggalDipilih!.year}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () async {
                          DateTime? tgl = await showDatePicker(
                            context: context,
                            initialDate: tanggalDipilih ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (tgl != null) {
                            setStatePopup(() {
                              tanggalDipilih = tgl;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _taskController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      setState(() {
                        // Update semua data pada index tersebut
                        todoList[index].judul = _taskController.text;
                        todoList[index].prioritas = prioritasDipilih;
                        todoList[index].deadline = tanggalDipilih;
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
      },
    );
  }

  // konfrimasi hapus
  // Fungsi untuk memunculkan popup konfirmasi hapus
  void _konfirmasiHapus(int index) {
    // Ambil judul untuk ditampilkan di pesan popup
    String judulYangAkanDihapus = todoList[index].judul;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "$judulYangAkanDihapus"?',
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog tanpa menghapus
              },
              child: const Text('Batal'),
            ),
            // Tombol Hapus (Berwarna merah agar hati-hati)
            TextButton(
              onPressed: () {
                setState(() {
                  todoList.removeAt(index); // Eksekusi hapus list
                  _simpanData(); // Simpan perubahan
                });
                Navigator.of(context).pop(); // Tutup dialog

                // Munculkan notifikasi Snackbar
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'List "$judulYangAkanDihapus" telah dihapus!',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
                  color: todoList[index].prioritas == 'Penting'
                      ? Colors.red.shade50
                      : (todoList[index].prioritas == 'Mendesak'
                            ? Colors.orange.shade50
                            : Colors.green.shade50),
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
                    subtitle: todoList[index].deadline != null
                        ? Text(
                            'Tenggat: ${todoList[index].deadline!.day}/${todoList[index].deadline!.month}/${todoList[index].deadline!.year}',
                          )
                        : null,
                    // Membungkus tombol Edit & Delete dalam satu baris (Row)
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Agar Row hanya memakan tempat sebesar tombol saja
                      children: [
                        // Tombol Edit (Pensil Biru)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _editList(
                              index,
                            ); // Panggil fungsi edit dengan index saat ini
                          },
                        ),

                        // Tombol Delete (Sampah Merah)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _konfirmasiHapus(
                              index,
                            ); // Panggil fungsi konfirmasi hapus
                          },
                        ),
                      ],
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
