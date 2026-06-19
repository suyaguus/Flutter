import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../main.dart'; // For tr() function

class TaskFormDialog extends StatefulWidget {
  final Todo? initialTodo;
  final void Function(String judul, String prioritas, DateTime? deadline) onSave;
  final VoidCallback? onDelete;

  const TaskFormDialog({
    super.key,
    this.initialTodo,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  late TextEditingController _taskController;
  late String prioritasDipilih;
  DateTime? tanggalDipilih;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.initialTodo?.judul ?? '');
    prioritasDipilih = widget.initialTodo?.prioritas ?? 'Tidak Mendesak';
    tanggalDipilih = widget.initialTodo?.deadline;
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  String translatePriority(String priority) {
    if (languageNotifier.value == 'id') return priority;
    switch (priority) {
      case 'Semua':
        return 'All';
      case 'Penting':
        return 'Important';
      case 'Mendesak':
        return 'Urgent';
      case 'Tidak Mendesak':
        return 'Not Urgent';
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialTodo != null;

    return AlertDialog(
      title: Text(
        isEdit
            ? tr('Edit Tugas', 'Edit Task')
            : tr('Tambah Tugas Baru', 'Add New Task'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: tr(
                  'Masukkan nama tugas...',
                  'Enter task name...',
                ),
                errorText: isError
                    ? tr('Nama tugas tidak boleh kosong!', 'Task name cannot be empty!')
                    : null,
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              onChanged: (value) {
                if (isError && value.trim().isNotEmpty) {
                  setState(() {
                    isError = false;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              tr('Prioritas:', 'Priority:'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: ['Penting', 'Mendesak', 'Tidak Mendesak'].map(
                (String val) {
                  bool isSelected = prioritasDipilih == val;
                  Color chipColor;
                  if (val == 'Penting') {
                    chipColor = Colors.red;
                  } else if (val == 'Mendesak') {
                    chipColor = Colors.orange;
                  } else {
                    chipColor = Colors.green;
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        prioritasDipilih = val;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? chipColor : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: chipColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        translatePriority(val),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                tanggalDipilih == null
                    ? tr('Tenggat Waktu: Belum diatur', 'Deadline: Not set')
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
                  setState(() {
                    tanggalDipilih = picked;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actionsAlignment: isEdit ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      actions: [
        if (isEdit && widget.onDelete != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete!();
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
                Navigator.of(context).pop();
              },
              child: Text(tr('Batal', 'Cancel')),
            ),
            TextButton(
              onPressed: () {
                if (_taskController.text.trim().isEmpty) {
                  setState(() {
                    isError = true;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tr('Nama tugas wajib diisi!', 'Task name is required!'),
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
                } else {
                  widget.onSave(
                    _taskController.text.trim(),
                    prioritasDipilih,
                    tanggalDipilih,
                  );
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEdit
                                  ? tr('Tugas berhasil diperbarui!', 'Task successfully updated!')
                                  : tr('Tugas berhasil ditambahkan!', 'Task successfully added!'),
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
              },
              child: Text(isEdit ? tr('Simpan', 'Save') : tr('Tambah', 'Add')),
            ),
          ],
        ),
      ],
    );
  }
}
