import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart'; // Import class Todo dari folder models
import 'settings_page.dart';

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

  // Tambahan State Pencarian
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Fungsi "Penyaring Cerdas" yang menggabungkan Filter & Sorting
  List<Todo> get listYangDitampilkan {
    List<Todo> hasil = todoList.where((todo) {
      // 1. Lulus Filter Prioritas
      bool cocokPrioritas =
          (filterPrioritas == 'Semua') || (todo.prioritas == filterPrioritas);

      // 2. Lulus Filter Pencarian (Judul atau Tanggal)
      bool cocokSearch = true;
      if (searchQuery.isNotEmpty) {
        String teksCari = searchQuery.toLowerCase();

        // Cek apakah judul cocok
        bool judulCocok = todo.judul.toLowerCase().contains(teksCari);

        // Cek apakah format tanggal cocok (misal: "12/8" atau "2026")
        bool tanggalCocok = false;
        if (todo.deadline != null) {
          String tanggalString =
              '${todo.deadline!.day}/${todo.deadline!.month}/${todo.deadline!.year}';
          tanggalCocok = tanggalString.contains(teksCari);
        }

        cocokSearch = judulCocok || tanggalCocok; // Lulus jika salah satu cocok
      }
      // Harus lulus prioritas DAN pencarian
      return cocokPrioritas && cocokSearch;
    }).toList();
    // 3. Urutkan berdasarkan tanggal terdekat
    if (sortDeadlineTerdekat) {
      hasil.sort((a, b) {
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
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
    // Ambil data yang sudah disaring dari fungsi cerdas kita
    List<Todo> daftarTampil = listYangDitampilkan;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Todo List'),
        actions: [
          // Tombol Ikon Roda Gigi
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () {
              // Pindah ke halaman Pengaturan
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),

      // Kita pakai Column untuk menumpuk Search Bar dan List Tugas
      body: Column(
        children: [
          // --- 1. BARIS PENCARIAN (Search Bar) ---
          // --- 1. CONTROL PANEL (Pencarian & Filter) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Kotak Pencarian
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau tanggal (Misal: 12/8)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),

                const SizedBox(height: 12), // Jarak antara pencarian dan filter
                // Baris Tombol Filter & Sort
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Jauhkan ke kiri dan kanan
                  children: [
                    // Bagian Filter (Kiri)
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: filterPrioritas,
                          underline:
                              const SizedBox(), // Menghilangkan garis bawah bawaan dropdown
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          items:
                              [
                                'Semua',
                                'Penting',
                                'Mendesak',
                                'Tidak Mendesak',
                              ].map((String choice) {
                                return DropdownMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              filterPrioritas = value!;
                            });
                          },
                        ),
                      ],
                    ),

                    // Bagian Sorting (Kanan)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          sortDeadlineTerdekat = !sortDeadlineTerdekat;
                        });
                      },
                      icon: Icon(
                        sortDeadlineTerdekat
                            ? Icons.schedule
                            : Icons.schedule_outlined,
                        color: sortDeadlineTerdekat ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      label: Text(
                        'Urutkan Tenggat',
                        style: TextStyle(
                          color: sortDeadlineTerdekat
                              ? Colors.red
                              : Colors.grey,
                          fontWeight: sortDeadlineTerdekat
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. AREA DAFTAR TUGAS ---
          // Menggunakan Expanded agar list mengambil sisa ruang layar secara penuh
          Expanded(
            child: daftarTampil.isEmpty
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
                          'Tidak ada catatan di sini!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: daftarTampil.length,
                    itemBuilder: (context, index) {
                      Todo item = daftarTampil[index];
                      int realIndex = todoList.indexOf(item);

                      return Card(
                        color: item.prioritas == 'Penting'
                            ? Colors.red.shade50
                            : (item.prioritas == 'Mendesak'
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
                            value: item.isSelesai,
                            // Tambahkan baris ini agar pinggiran kotak selalu berwarna gelap
                            side: const BorderSide(
                              color: Colors.black54,
                              width: 2,
                            ),
                            onChanged: (bool? nilaiBaru) {
                              setState(() {
                                todoList[realIndex].isSelesai = nilaiBaru!;
                                _simpanData();
                              });
                            },
                          ),

                          title: Text(
                            item.judul,
                            style: TextStyle(
                              // Tambahkan baris ini agar teks selalu hitam tegas
                              color: Colors.black87,
                              decoration: item.isSelesai
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),

                          subtitle: item.deadline != null
                              ? Text(
                                  'Tenggat: ${item.deadline!.day}/${item.deadline!.month}/${item.deadline!.year}',
                                  // Tambahkan baris style ini
                                  style: const TextStyle(color: Colors.black54),
                                )
                              : null,

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _editList(realIndex);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _konfirmasiHapus(realIndex);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ), // Akhir Expanded
        ],
      ), // Akhir Column

      floatingActionButton: FloatingActionButton(
        onPressed: _tambahList,
        tooltip: 'Tambah List',
        child: const Icon(Icons.add),
      ),
    );
  }
}
