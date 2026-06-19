import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'settings_page.dart';
import '../main.dart'; // Impor untuk mengambil fungsi tr()

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todoList = [];
  final TextEditingController _taskController = TextEditingController();

  // --- STATE UNTUK FILTER, SORTING, & SEARCH ---
  String filterPrioritas = 'Semua';
  bool sortDeadlineTerdekat = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    String prioritasDipilih = "Tidak Mendesak";
    DateTime? tanggalDipilih;
    bool isError = false;

    // --- MENGGUNAKAN showGeneralDialog UNTUK ANIMASI IN/OUT KUSTOM ---
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
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(tr('Tambah Tugas Baru', 'Add New Task')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: tr('Nama Tugas', 'Task Name'),
                      errorText: isError
                          ? tr(
                              'Nama tugas tidak boleh kosong!',
                              'Task name cannot be empty!',
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- MENGGANTI DROPDOWN DENGAN TOMBOL ANIMASI ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Prioritas:', 'Priority:'),
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['Penting', 'Mendesak', 'Tidak Mendesak'].map((
                          String val,
                        ) {
                          bool isSelected = prioritasDipilih == val;
                          // Menentukan warna tombol berdasarkan prioritas
                          Color chipColor = val == 'Penting'
                              ? Colors.red
                              : (val == 'Mendesak'
                                    ? Colors.orange
                                    : Colors.green);

                          return GestureDetector(
                            onTap: () {
                              setStateDialog(() {
                                prioritasDipilih = val;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves
                                  .easeOutCubic, // Animasi transisi yang halus
                              padding: EdgeInsets.symmetric(
                                vertical: isSelected ? 10 : 6,
                                horizontal: isSelected ? 14 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? chipColor
                                    : Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: chipColor.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                translatePriority(val),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      tanggalDipilih == null
                          ? tr(
                              'Tenggat Waktu: Belum diatur',
                              'Deadline: Not set',
                            )
                          : '${tr('Tenggat:', 'Deadline:')} ${tanggalDipilih!.day}/${tanggalDipilih!.month}/${tanggalDipilih!.year}',
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          tanggalDipilih = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _taskController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text(tr('Batal', 'Cancel')),
                ),
                TextButton(
                  onPressed: () {
                    // JIKA INPUTAN KOSONG:
                    if (_taskController.text.trim().isEmpty) {
                      setStateDialog(() {
                        isError = true;
                      });

                      // --- TAMPILKAN SNACKBAR PERINGATAN MERAH ---
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red.shade600, // Warna merah
                          behavior:
                              SnackBarBehavior.floating, // Desain melayang
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          content: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tr(
                                    'Nama tugas wajib diisi!',
                                    'Task name is required!',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    // JIKA INPUTAN BENAR (TERISI):
                    else {
                      setState(() {
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr(
                              'Tugas berhasil ditambahkan!',
                              'Task successfully added!',
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(tr('Tambah', 'Add')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editList(int index) {
    _taskController.text = todoList[index].judul;
    String prioritasDipilih = todoList[index].prioritas;
    DateTime? tanggalDipilih = todoList[index].deadline;
    bool isError = false;

    if (!['Penting', 'Mendesak', 'Tidak Mendesak'].contains(prioritasDipilih)) {
      prioritasDipilih = 'Tidak Mendesak';
    }

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
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(tr('Edit Tugas', 'Edit Task')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: tr('Nama Tugas', 'Task Name'),
                      errorText: isError
                          ? tr(
                              'Nama tugas tidak boleh kosong!',
                              'Task name cannot be empty!',
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- MENGGANTI DROPDOWN DENGAN TOMBOL ANIMASI ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Prioritas:', 'Priority:'),
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['Penting', 'Mendesak', 'Tidak Mendesak'].map(
                          (String val) {
                            bool isSelected = prioritasDipilih == val;
                            Color chipColor = val == 'Penting'
                                ? Colors.red
                                : (val == 'Mendesak'
                                      ? Colors.orange
                                      : Colors.green);

                            return GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  prioritasDipilih = val;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                padding: EdgeInsets.symmetric(
                                  vertical: isSelected ? 10 : 6,
                                  horizontal: isSelected ? 14 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? chipColor
                                      : Colors.grey.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: chipColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  translatePriority(val),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      tanggalDipilih == null
                          ? tr(
                              'Tenggat Waktu: Belum diatur',
                              'Deadline: Not set',
                            )
                          : '${tr('Tenggat:', 'Deadline:')} ${tanggalDipilih!.day}/${tanggalDipilih!.month}/${tanggalDipilih!.year}',
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tanggalDipilih ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          tanggalDipilih = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _konfirmasiHapus(index);
                  },
                  child: Text(
                    tr('Hapus', 'Delete'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        _taskController.clear();
                        Navigator.of(context).pop();
                      },
                      child: Text(tr('Batal', 'Cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        // JIKA INPUTAN KOSONG SAAT EDIT:
                        if (_taskController.text.trim().isEmpty) {
                          setStateDialog(() {
                            isError = true;
                          });

                          // --- TAMPILKAN SNACKBAR PERINGATAN MERAH ---
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      tr(
                                        'Nama tugas wajib diisi!',
                                        'Task name is required!',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        // JIKA INPUTAN BENAR:
                        else {
                          setState(() {
                            todoList[index].judul = _taskController.text;
                            todoList[index].prioritas = prioritasDipilih;
                            todoList[index].deadline = tanggalDipilih;
                            _simpanData();
                          });
                          _taskController.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(tr('Simpan', 'Save')),
                    ),
                  ],
                ),
              ],
            );
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

  // --- WIDGET DASHBOARD PROGRESS BAR ---
  Widget _buildProgressBar() {
    int totalTugas = todoList.length;
    // Menghitung berapa banyak tugas yang isSelesai == true
    int tugasSelesai = todoList.where((t) => t.isSelesai).length;
    // Menghindari error pembagian dengan nol
    double progress = totalTugas == 0 ? 0.0 : tugasSelesai / totalTugas;

    // Menyiapkan teks motivasi
    String pesanTeks = '';
    if (totalTugas == 0) {
      pesanTeks = tr(
        'Belum ada tugas, ayo buat sekarang!',
        'No tasks yet, create one now!',
      );
    } else if (tugasSelesai == totalTugas) {
      pesanTeks = tr(
        'Luar biasa! Semua tugas selesai 🎉',
        'Awesome! All tasks completed 🎉',
      );
    } else {
      pesanTeks = tr(
        'Anda telah menyelesaikan $tugasSelesai dari $totalTugas tugas.',
        'You have completed $tugasSelesai of $totalTugas tasks.',
      );
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Efek Gradasi warna Ungu yang elegan
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('Ringkasan Tugas', 'Task Summary'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.analytics, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pesanTeks,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // --- Animasi Garis Progres ---
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(
              milliseconds: 1000,
            ), // Bergerak mulus selama 1 detik
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Column(
                children: [
                  Stack(
                    children: [
                      // Rel Belakang (Abu-abu transparan)
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Rel Depan (Putih solid yang bergerak memanjang)
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Teks Persentase yang ikut berjalan naik/turun
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> daftarTampil = listYangDitampilkan;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('My Todo List'),
        actions: [
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
          // MEMUNCULKAN DASHBOARD DI SINI
          _buildProgressBar(),

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
                          // Sensor untuk mendeteksi "Tahan Lama" (sekitar setengah hingga 1 detik)
                          onLongPress: () {
                            _editList(realIndex); // Buka popup detail
                          },
                          leading: Checkbox(
                            value: item.isSelesai,
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
                              color: Colors.black87,
                              decoration: item.isSelesai
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: item.deadline != null
                              ? Text(
                                  '${tr('Tenggat:', 'Deadline:')} ${item.deadline!.day}/${item.deadline!.month}/${item.deadline!.year}',
                                  style: const TextStyle(color: Colors.black54),
                                )
                              : null,
                          // PENTING: Bagian 'trailing' yang berisi ikon edit dan hapus sudah kita hapus sepenuhnya!
                        ),
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
