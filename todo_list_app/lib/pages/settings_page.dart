import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Untuk memanggil themeNotifier

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode =
      false; // Sementara, nanti kita hubungkan dengan logika utama

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // ListView agar halamannya bisa di-scroll jika isinya panjang
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
            // Cek apakah tema pusat saat ini adalah mode gelap
            value: themeNotifier.value == ThemeMode.dark,
            secondary: const Icon(Icons.dark_mode),
            onChanged: (bool value) async {
              // 1. Ubah tampilan secara langsung secara instan
              setState(() {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              });

              // 2. Simpan pilihan ke memori (SharedPreferences)
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isDarkMode', value);
            },
          ),

          const Divider(), // Garis pemisah
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
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.orange),
            title: const Text('Bersihkan Tugas Selesai'),
            subtitle: const Text('Hapus semua tugas yang sudah dicentang'),
            onTap: () {
              // (Nanti kita tambahkan popup konfirmasi hapus di sini)
            },
          ),
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
              // (Nanti kita tambahkan popup konfirmasi hapus di sini)
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
            subtitle: Text(
              'Dikembangkan oleh Surya Agung Firdaus',
            ), // Anda bisa menggantinya dengan nama/studio Anda
          ),
        ],
      ),
    );
  }
}
