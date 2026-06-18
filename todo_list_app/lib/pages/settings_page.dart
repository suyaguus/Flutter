import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Untuk memanggil themeNotifier dan tr()

class SettingsPage extends StatefulWidget {
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
        title: Text(tr('Pengaturan', 'Settings')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // --- BAGIAN TAMPILAN ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              tr('Tampilan', 'Appearance'),
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(tr('Mode Gelap (Dark Mode)', 'Dark Mode')),
            subtitle: Text(
              tr(
                'Ubah tema aplikasi menjadi gelap',
                'Change app theme to dark',
              ),
            ),
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

          // Menu Pilihan Bahasa
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(tr('Bahasa Aplikasi', 'App Language')),
            subtitle: Text(tr('Indonesia', 'English')),
            trailing: DropdownButton<String>(
              value: languageNotifier.value,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'id', child: Text('🇮🇩 Indonesia')),
                DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
              ],
              onChanged: (String? value) async {
                if (value != null) {
                  setState(() {
                    languageNotifier.value = value;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('language', value);
                }
              },
            ),
          ),
          const Divider(),

          // --- BAGIAN MANAJEMEN DATA ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              tr('Manajemen Data', 'Data Management'),
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tombol Bersihkan Selesai
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.orange),
            title: Text(tr('Bersihkan Tugas Selesai', 'Clear Completed Tasks')),
            subtitle: Text(
              tr(
                'Hapus semua tugas yang sudah dicentang',
                'Delete all checked tasks',
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    tr('Bersihkan Tugas Selesai?', 'Clear Completed Tasks?'),
                  ),
                  content: Text(
                    tr(
                      'Semua tugas yang sudah dicentang akan dihapus selamanya.',
                      'All checked tasks will be permanently deleted.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(tr('Batal', 'Cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onBersihkanSelesai();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr(
                                'Tugas selesai telah dibersihkan!',
                                'Completed tasks have been cleared!',
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        tr('Bersihkan', 'Clear'),
                        style: const TextStyle(color: Colors.orange),
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
            title: Text(
              tr('Hapus Semua Data', 'Clear All Data'),
              style: const TextStyle(color: Colors.red),
            ),
            subtitle: Text(
              tr(
                'Kosongkan seluruh daftar tugas secara permanen',
                'Empty the entire task list permanently',
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(tr('Peringatan Bahaya!', 'Danger Warning!')),
                  content: Text(
                    tr(
                      'Apakah Anda yakin ingin menghapus SELURUH daftar tugas? Tindakan ini tidak bisa dibatalkan.',
                      'Are you sure you want to delete the ENTIRE task list? This action cannot be undone.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(tr('Batal', 'Cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onHapusSemua();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr(
                                'Seluruh data telah dihapus!',
                                'All data has been deleted!',
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        tr('Hapus Semua', 'Delete All'),
                        style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              tr('Info Aplikasi', 'App Info'),
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('My Todo List v1.0.0'),
            subtitle: Text(
              tr(
                'Dikembangkan oleh Surya Agung Firdaus',
                'Developed by Surya Agung Firdaus',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
