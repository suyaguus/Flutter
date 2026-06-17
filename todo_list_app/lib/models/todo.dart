class Todo {
  String judul;
  bool isSelesai;

  // constructor
  Todo({required this.judul, this.isSelesai = false});

  Map<String, dynamic> toMap() {
    return {'judul': judul, 'isSelesai': isSelesai};
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(judul: map['judul'], isSelesai: map['isSelesai']);
  }
}
