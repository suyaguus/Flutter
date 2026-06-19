import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'settings_page.dart';
import '../main.dart'; // Impor untuk mengambil fungsi tr()
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../widgets/progress_dashboard.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todoList = [];
  // --- STATE UNTUK FILTER, SORTING, & SEARCH ---
  String filterPrioritas = 'Semua';
  bool sortDeadlineTerdekat = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool isGridView = false; // <-- STATE UNTUK MODE GRID

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todoString = prefs.getString('todoList');
    if (todoString != null) {
      final List<dynamic> decoded = jsonDecode(todoString);
      setState(() {
        todoList = decoded
            .map((item) => Todo.fromMap(item))
            .toList(); // INI BENAR
      });
    }
  }

  Future<void> _simpanData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      todoList.map((item) => item.toMap()).toList(), // INI BENAR
    );

    await prefs.setString('todoList', encoded);
  }

  // Fungsi khusus untuk menerjemahkan teks Dropdown Prioritas
  String translatePriority(String priority) {
    if (priority == 'Semua') return tr('Semua', 'All');
    if (priority == 'Penting') return tr('Penting', 'Important');
    if (priority == 'Mendesak') return tr('Mendesak', 'Urgent');
    if (priority == 'Tidak Mendesak') return tr('Tidak Mendesak', 'Not Urgent');
    return priority;
  }

  void _tambahList() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup Popup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return TaskFormDialog(
          onSave: (judul, prioritas, deadline) {
            setState(() {
              todoList.add(
                Todo(
                  judul: judul,
                  prioritas: prioritas,
                  deadline: deadline,
                ),
              );
              _simpanData();
            });
          },
        );
      },
    );
  }

  void _editList(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup Popup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return TaskFormDialog(
          initialTodo: todoList[index],
          onDelete: () {
            _konfirmasiHapus(index);
          },
          onSave: (judul, prioritas, deadline) {
            setState(() {
              todoList[index].judul = judul;
              todoList[index].prioritas = prioritas;
              todoList[index].deadline = deadline;
              _simpanData();
            });
          },
        );
      },
    );
  }

  void _konfirmasiHapus(int index) {
    // --- MENGGUNAKAN showGeneralDialog UNTUK ANIMASI KUSTOM ---
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // Bisa ditutup dengan ketuk di luar
      barrierLabel: 'Tutup Popup',
      barrierColor: Colors.black54, // Latar belakang redup
      transitionDuration: const Duration(milliseconds: 400), // Durasi halus
      // MENGATUR EFEK ANIMASI IN / OUT
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          // Efek membesar (Scale) dengan pantulan (easeOutBack)
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            // Efek memudar perlahan (Fade)
            opacity: animation,
            child: child,
          ),
        );
      },

      // ISI DARI POPUP (Sama seperti sebelumnya)
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: Text(tr('Hapus Tugas?', 'Delete Task?')),
          content: Text(
            tr(
              'Apakah Anda yakin ingin menghapus tugas ini?',
              'Are you sure you want to delete this task?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(tr('Batal', 'Cancel')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  todoList.removeAt(index);
                  _simpanData();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr(
                        'Tugas berhasil dihapus!',
                        'Task successfully deleted!',
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                tr('Hapus', 'Delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _bersihkanTugasSelesai() {
    setState(() {
      todoList.removeWhere((item) => item.isSelesai);
      _simpanData();
    });
  }

  void _hapusSemuaData() {
    setState(() {
      todoList.clear();
      _simpanData();
    });
  }

  List<Todo> get listYangDitampilkan {
    List<Todo> hasil = todoList.where((todo) {
      bool cocokPrioritas =
          (filterPrioritas == 'Semua') || (todo.prioritas == filterPrioritas);
      bool cocokSearch = true;
      if (searchQuery.isNotEmpty) {
        String teksCari = searchQuery.toLowerCase();
        bool judulCocok = todo.judul.toLowerCase().contains(teksCari);
        bool tanggalCocok = false;
        if (todo.deadline != null) {
          String tanggalString =
              '${todo.deadline!.day}/${todo.deadline!.month}/${todo.deadline!.year}';
          tanggalCocok = tanggalString.contains(teksCari);
        }
        cocokSearch = judulCocok || tanggalCocok;
      }
      return cocokPrioritas && cocokSearch;
    }).toList();

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

  // --- FUNGSI REORDER (SERET DAN SUSUN) ---
  void _onReorder(int oldIndex, int newIndex) {
    if (searchQuery.isNotEmpty || filterPrioritas != 'Semua' || sortDeadlineTerdekat) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Tidak bisa menyusun saat filter/pencarian aktif!', 'Cannot reorder while filtering/searching!'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1; // Penyesuaian indeks karena item dihapus dulu
      }
      final Todo item = todoList.removeAt(oldIndex);
      todoList.insert(newIndex, item);
      _simpanData();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> daftarTampil = listYangDitampilkan;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Todo List'),
        actions: [
          // --- TOMBOL TOGGLE GRID / LIST ---
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: isGridView ? tr('Mode List', 'List Mode') : tr('Mode Grid', 'Grid Mode'),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: tr('Pengaturan', 'Settings'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    onBersihkanSelesai: _bersihkanTugasSelesai,
                    onHapusSemua: _hapusSemuaData,
                  ),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ProgressDashboard(
            totalTugas: todoList.length,
            tugasSelesai: todoList.where((t) => t.isSelesai).length,
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: tr(
                      'Cari tugas atau tanggal (Misal: 12/8)...',
                      'Search for a task or date (e.g., 12/8)...',
                    ),
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                          underline: const SizedBox(),
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
                                  child: Text(translatePriority(choice)),
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
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          sortDeadlineTerdekat = !sortDeadlineTerdekat;
                        });
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              sortDeadlineTerdekat
                                  ? tr(
                                      'Mengurutkan tenggat terdekat',
                                      'Sorting by nearest deadline',
                                    )
                                  : tr('Urutan normal', 'Normal order'),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(
                        sortDeadlineTerdekat
                            ? Icons.schedule
                            : Icons.schedule_outlined,
                        color: sortDeadlineTerdekat ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      label: Text(
                        tr('Urutkan Tenggat', 'Sort Deadlines'),
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
          Expanded(
            child: daftarTampil.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_turned_in,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr('Tidak ada catatan di sini!', 'No notes here!'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : isGridView
                    ? ReorderableGridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 Kolom
                          childAspectRatio: 1.1, // Agar kotak tidak terlalu pipih
                        ),
                        itemCount: daftarTampil.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          Todo item = daftarTampil[index];
                          int realIndex = todoList.indexOf(item);
                          return TaskCard(
                            key: ObjectKey(item),
                            item: item,
                            isGridView: true,
                            onTap: () => _editList(realIndex),
                            onCheckboxChanged: (bool? nilaiBaru) {
                              setState(() {
                                todoList[realIndex].isSelesai = nilaiBaru!;
                                _simpanData();
                              });
                            },
                          );
                        },
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        itemCount: daftarTampil.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          Todo item = daftarTampil[index];
                          int realIndex = todoList.indexOf(item);
                          return TaskCard(
                            key: ObjectKey(item),
                            item: item,
                            isGridView: false,
                            onTap: () => _editList(realIndex),
                            onCheckboxChanged: (bool? nilaiBaru) {
                              setState(() {
                                todoList[realIndex].isSelesai = nilaiBaru!;
                                _simpanData();
                              });
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahList,
        tooltip: tr('Tambah Tugas', 'Add Task'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
