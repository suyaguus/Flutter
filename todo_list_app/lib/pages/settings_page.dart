import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Untuk memanggil themeNotifier

class SettingsPage extends StatefulWidget {
  // Menerima kabel penghubung dari halaman utama
  final VoidCallback onBersihkanSelesai;
  final VoidCallback onHapusSemua;

  const SettingsPage({
    super.key,
    required this.onBersihkanSelesai,
    required this.onHapusSemua,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // --- BAGIAN TAMPILAN ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tampilan',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Mode Gelap (Dark Mode)'),
            subtitle: const Text('Ubah tema aplikasi menjadi gelap'),
            value: themeNotifier.value == ThemeMode.dark,
            secondary: const Icon(Icons.dark_mode),
            onChanged: (bool value) async {
              setState(() {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isDarkMode', value);
            },
          ),
          const Divider(),

          // --- BAGIAN MANAJEMEN DATA ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manajemen Data',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tombol Bersihkan Selesai
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.orange),
            title: const Text('Bersihkan Tugas Selesai'),
            subtitle: const Text('Hapus semua tugas yang sudah dicentang'),
            onTap: () {
              // Munculkan Popup Konfirmasi
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Bersihkan Tugas Selesai?'),
                  content: const Text(
                    'Semua tugas yang sudah dicentang akan dihapus selamanya.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        widget
                            .onBersihkanSelesai(); // Panggil fungsi dari halaman utama
                        Navigator.pop(context); // Tutup dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tugas selesai telah dibersihkan!'),
                          ),
                        );
                      },
                      child: const Text(
                        'Bersihkan',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Tombol Hapus Semua
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Hapus Semua Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
              'Kosongkan seluruh daftar tugas secara permanen',
            ),
            onTap: () {
              // Munculkan Popup Konfirmasi Bahaya
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Peringatan Bahaya!'),
                  content: const Text(
                    'Apakah Anda yakin ingin menghapus SELURUH daftar tugas? Tindakan ini tidak bisa dibatalkan.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        widget
                            .onHapusSemua(); // Panggil fungsi dari halaman utama
                        Navigator.pop(context); // Tutup dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Seluruh data telah dihapus!'),
                          ),
                        );
                      },
                      child: const Text(
                        'Hapus Semua',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // --- BAGIAN INFO ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Info Aplikasi',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('My Todo List v1.0.0'),
            subtitle: Text('Dikembangkan oleh Surya Agung Firdaus'),
          ),
        ],
      ),
    );
  }
}
