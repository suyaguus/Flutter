class Todo {
  String judul;
  bool isSelesai;
  // prioritas untuk list
  String prioritas; // Penting, Mendesak, Tidak Mendesak
  DateTime? deadline;

  // constructor
  Todo({
    required this.judul,
    this.isSelesai = false,
    this.prioritas = "Tidak Mendesak",
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'isSelesai': isSelesai,
      'prioritas': prioritas,
      'deadline': deadline?.toIso8601String(), // Ubah format tanggal ke teks
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      judul: map['judul'],
      isSelesai: map['isSelesai'],
      prioritas: map['prioritas'] ?? "Tidak Mendesak",
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
    );
  }
}
