import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wintrack/core/database/db_helper.dart';
import 'package:wintrack/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  Future<void> _exportDatabase() async {
    setState(() { _isLoading = true; });
    try {
      final dbPath = await DBHelper.instance.getDatabaseFilePath();
      final File dbFile = File(dbPath);
      
      if (!await dbFile.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database tidak ditemukan.')));
        return;
      }

      final dbBytes = await dbFile.readAsBytes();
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Backup Wintrack',
        fileName: 'wintrack_backup.db',
        bytes: dbBytes,
      );

      if (outputFile != null) {
        try {
          await dbFile.copy(outputFile);
        } catch (e) {
          // In some platforms, saveFile with bytes already writes the file.
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menyimpan backup!')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengekspor: $e')));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _importDatabase() async {
    setState(() { _isLoading = true; });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Pilih File Backup Wintrack',
      );

      if (result != null && result.files.single.path != null) {
        final File backupFile = File(result.files.single.path!);
        final dbPath = await DBHelper.instance.getDatabaseFilePath();
        
        // Copy the chosen file to the app's database location
        await backupFile.copy(dbPath);
        
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Restore Berhasil'),
            content: const Text('Data berhasil dikembalikan. Silakan restart aplikasi (tutup dari recent apps dan buka lagi) agar perubahan terlihat.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengimpor: $e')));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text('Pengaturan', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        clipBehavior: Clip.antiAlias,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Backup & Restore',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE8EAED)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.upload_file, color: AppTheme.primaryColor),
                          title: const Text('Ekspor Data'),
                          subtitle: const Text('Simpan progress Anda ke file lokal'),
                          onTap: _exportDatabase,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.download, color: AppTheme.secondaryColor),
                          title: const Text('Impor Data'),
                          subtitle: const Text('Pulihkan progress dari file backup'),
                          onTap: _importDatabase,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Tentang',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE8EAED)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.grey),
                      title: const Text('Wintrack'),
                      subtitle: const Text('Versi 1.0.0'),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Wintrack',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 Wintrack Developer',
                          children: [
                            const SizedBox(height: 16),
                            const Text('Aplikasi pelacakan aktivitas harian dengan gamifikasi tingkat tinggi untuk membantu Anda membangun kebiasaan yang lebih baik.'),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
