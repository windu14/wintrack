import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wintrack/core/theme/app_theme.dart';
import 'package:wintrack/features/activity/presentation/add_activity_screen.dart';
import 'package:wintrack/features/activity/presentation/providers/activity_provider.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  late ScrollController _calendarScrollController;
  final int _daysOffset = 30; // 30 days before and after today

  @override
  void initState() {
    super.initState();
    _calendarScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll to today (roughly center)
      if (_calendarScrollController.hasClients) {
        // Each item is about 64 pixels wide
        _calendarScrollController.jumpTo((_daysOffset - 2) * 64.0);
      }
    });
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  bool _isPastDay(DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return selected.isBefore(today);
  }

  Widget _getEmoteIcon(double progress) {
    if (progress == 0.0) {
      return const Icon(Icons.sentiment_dissatisfied, color: Colors.grey, size: 28);
    } else if (progress < 1.0) {
      return const Icon(Icons.sentiment_satisfied_alt, color: AppTheme.primaryColor, size: 28);
    } else {
      return const Icon(Icons.sentiment_very_satisfied, color: AppTheme.secondaryColor, size: 28);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sangat Penting':
        return Colors.red.shade400;
      case 'Penting':
        return Colors.orange.shade400;
      case 'Sedang':
        return AppTheme.primaryColor;
      case 'Tidak Terlalu':
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final activitiesState = ref.watch(activityListProvider);
    final progress = ref.watch(dailyProgressProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor, // Background di balik curve
      appBar: AppBar(
        title: const Text('Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(), // Reset shape
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, selectedDate, progress),
            _buildCalendarRow(selectedDate),
            const SizedBox(height: 8),
            Expanded(
              child: activitiesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (activities) {
                  if (activities.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada aktivitas hari ini.\nTekan + untuk menambahkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final isPast = _isPastDay(selectedDate);

                  return ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return Dismissible(
                        key: Key('activity_${activity.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) {
                          ref.read(activityListProvider.notifier)
                             .deleteActivity(activity.id!, selectedDate);
                        },
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Checkbox(
                              value: activity.isCompleted,
                              onChanged: isPast ? null : (val) {
                                ref.read(activityListProvider.notifier)
                                   .toggleActivityCompletion(activity, selectedDate);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            title: Text(
                              activity.title,
                              style: TextStyle(
                                decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
                                fontWeight: FontWeight.w600,
                                color: isPast && !activity.isCompleted ? Colors.grey : const Color(0xFF202124),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (activity.description != null && activity.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(activity.description!),
                                  ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(activity.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _getStatusColor(activity.status).withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    activity.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(activity.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddActivityScreen(),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime date, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE', 'id_ID').format(date),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMMM yyyy', 'id_ID').format(date),
                style: const TextStyle(fontSize: 16, color: Color(0xFF5F6368)),
              ),
            ],
          ),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFE8EAED),
                  color: progress == 1.0 ? AppTheme.secondaryColor : AppTheme.primaryColor,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarRow(DateTime selectedDate) {
    final today = DateTime.now();
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: ListView.builder(
        controller: _calendarScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _daysOffset * 2 + 1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final targetDate = today.add(Duration(days: index - _daysOffset));
          final isSelected = targetDate.year == selectedDate.year &&
              targetDate.month == selectedDate.month &&
              targetDate.day == selectedDate.day;

          // Fetch day progress
          final dayProgressAsync = ref.watch(dayProgressProvider(targetDate));

          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).updateDate(targetDate);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'id_ID').format(targetDate),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : const Color(0xFF5F6368),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${targetDate.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : const Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 4),
                  dayProgressAsync.when(
                    data: (prog) => _getEmoteIcon(prog),
                    loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, _) => const Icon(Icons.error, size: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
