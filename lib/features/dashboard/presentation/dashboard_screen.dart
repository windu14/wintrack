import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wintrack/core/theme/app_theme.dart';
import 'package:wintrack/features/activity/presentation/providers/activity_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyProgressProvider);
    final scoreAsync = ref.watch(lifetimeScoreProvider);
    final score = scoreAsync.value ?? 0;
    
    // Level calc based on lifetime score
    final level = 1 + (score ~/ 100);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text('Beranda', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.sp)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: _buildGreetingCard(level, progress, score).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDashboardCards(context).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(int level, double progress, int score) {
    int fireLevel = (progress * 5).ceil();
    if (fireLevel < 1) fireLevel = 1;
    if (fireLevel > 5) fireLevel = 5;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppTheme.modernShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang kembali!',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Level $level',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Skor Total: $score',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.amberAccent,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Progres Hari Ini: ${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    color: AppTheme.secondaryColor,
                    minHeight: 8.h,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Lottie Animation Widget
          SizedBox(
            width: 120.w,
            height: 150.h,
            child: progress == 0.0 
              ? ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ]),
                  child: Lottie.asset(
                    'assets/animations/fire_$fireLevel.json',
                    fit: BoxFit.contain,
                    animate: false,
                  ),
                )
              : Lottie.asset(
                  'assets/animations/fire_$fireLevel.json',
                  fit: BoxFit.contain,
                ),
          ),
        ],
      ),
    );
  }



  Widget _buildDashboardCards(BuildContext context) {
    return Column(
      children: [
        _buildCTA(context),
        SizedBox(height: 16.h),
        _buildChallengeCard(),
        SizedBox(height: 16.h),
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildChallengeCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.modernShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tantangan Hari Ini',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Selesaikan 3 aktivitas untuk bonus skor!',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
              ],
            ),
          ),
          Icon(Icons.local_fire_department, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.modernShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kenapa Mencatat?',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Mencatat aktivitas membantumu tetap fokus.',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
              ],
            ),
          ),
          const Icon(Icons.lightbulb_outline, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // CTA logic, maybe switch tab
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34A853), Color(0xFF2E8B57)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: AppTheme.modernShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Punya aktivitas baru?',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Catat sekarang agar tidak lupa!',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
