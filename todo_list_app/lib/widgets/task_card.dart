import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../main.dart'; // For tr() function

class TaskCard extends StatelessWidget {
  final Todo item;
  final bool isGridView;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;

  const TaskCard({
    super.key, // Allows passing a key (like ObjectKey for reordering)
    required this.item,
    required this.isGridView,
    required this.onTap,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.prioritas == 'Penting'
          ? Colors.red.shade50
          : (item.prioritas == 'Mendesak'
              ? Colors.orange.shade50
              : Colors.green.shade50),
      margin: EdgeInsets.symmetric(
        horizontal: isGridView ? 8 : 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: isGridView
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.judul,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: item.isSelesai
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: item.isSelesai,
                            activeColor: Colors.deepPurple,
                            side: const BorderSide(
                                color: Colors.black54, width: 2),
                            onChanged: onCheckboxChanged,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (item.deadline != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            '${item.deadline!.day}/${item.deadline!.month}/${item.deadline!.year}',
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              )
            : ListTile(
                leading: Checkbox(
                  value: item.isSelesai,
                  activeColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.black54, width: 2),
                  onChanged: onCheckboxChanged,
                ),
                title: Text(
                  item.judul,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
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
              ),
      ),
    );
  }
}
