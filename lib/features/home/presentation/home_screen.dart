import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wintrack/core/theme/app_theme.dart';
import 'package:wintrack/features/activity/presentation/add_activity_screen.dart';
import 'package:wintrack/features/activity/presentation/providers/activity_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final activitiesState = ref.watch(activityListProvider);
    final progress = ref.watch(dailyProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wintrack', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                ref.read(selectedDateProvider.notifier).updateDate(date);
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, selectedDate, progress),
          const SizedBox(height: 16),
          Expanded(
            child: activitiesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (activities) {
                if (activities.isEmpty) {
                  return const Center(
                    child: Text(
                      'No activities for this day.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: activity.isCompleted,
                          onChanged: (val) {
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
                          ),
                        ),
                        subtitle: activity.description != null && activity.description!.isNotEmpty
                            ? Text(activity.description!)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                          onPressed: () {
                            ref.read(activityListProvider.notifier)
                               .deleteActivity(activity.id!, selectedDate);
                          },
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
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE').format(date),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM d, yyyy').format(date),
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
                  color: AppTheme.secondaryColor,
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
}

