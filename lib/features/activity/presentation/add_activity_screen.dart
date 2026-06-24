import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wintrack/features/activity/domain/activity_model.dart';
import 'package:wintrack/features/activity/presentation/providers/activity_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wintrack/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedStatus = 'Sedang';

  final List<String> _statusOptions = [
    'Sangat Penting',
    'Penting',
    'Sedang',
    'Tidak Terlalu',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      final selectedDate = ref.read(selectedDateProvider);
      final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);
      
      final newActivity = ActivityModel(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: dateString,
        createdAt: DateTime.now().toIso8601String(),
        status: _selectedStatus,
      );

      ref.read(activityListProvider.notifier).addActivity(newActivity, selectedDate);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text('Tambah Aktivitas', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.sp)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul Aktivitas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      prefixIcon: const Icon(Icons.task_alt),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mohon masukkan judul';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi (Opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 24.h),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Prioritas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                    items: _statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 48.h),
                  ElevatedButton(
                    onPressed: _saveActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Simpan Aktivitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
