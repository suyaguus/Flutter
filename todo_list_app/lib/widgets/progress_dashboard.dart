import 'package:flutter/material.dart';
import '../main.dart';

class ProgressDashboard extends StatelessWidget {
  final int totalTugas;
  final int tugasSelesai;

  const ProgressDashboard({
    super.key,
    required this.totalTugas,
    required this.tugasSelesai,
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalTugas == 0 ? 0.0 : tugasSelesai / totalTugas;

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
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
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
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
}
