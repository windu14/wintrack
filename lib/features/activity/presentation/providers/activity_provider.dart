import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wintrack/features/activity/data/activity_repository.dart';
import 'package:wintrack/features/activity/domain/activity_model.dart';

// Provider for the repository
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

// Provider for the selected date on the dashboard
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime date) {
    state = date;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(() {
  return SelectedDateNotifier();
});

// Notifier for managing the list of activities
class ActivityListNotifier extends AsyncNotifier<List<ActivityModel>> {
  @override
  Future<List<ActivityModel>> build() async {
    final date = ref.watch(selectedDateProvider);
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return await ref.read(activityRepositoryProvider).getActivitiesByDate(dateString);
  }

  Future<void> addActivity(ActivityModel activity, DateTime currentDate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(activityRepositoryProvider).createActivity(activity);
      final dateString = DateFormat('yyyy-MM-dd').format(currentDate);
      ref.invalidate(dayProgressProvider(currentDate));
      return await ref.read(activityRepositoryProvider).getActivitiesByDate(dateString);
    });
  }

  Future<void> toggleActivityCompletion(ActivityModel activity, DateTime currentDate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedActivity = activity.copyWith(isCompleted: !activity.isCompleted);
      await ref.read(activityRepositoryProvider).updateActivity(updatedActivity);
      final dateString = DateFormat('yyyy-MM-dd').format(currentDate);
      ref.invalidate(dayProgressProvider(currentDate));
      return await ref.read(activityRepositoryProvider).getActivitiesByDate(dateString);
    });
  }

  Future<void> deleteActivity(int id, DateTime currentDate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(activityRepositoryProvider).deleteActivity(id);
      final dateString = DateFormat('yyyy-MM-dd').format(currentDate);
      ref.invalidate(dayProgressProvider(currentDate));
      return await ref.read(activityRepositoryProvider).getActivitiesByDate(dateString);
    });
  }
}

final activityListProvider = AsyncNotifierProvider<ActivityListNotifier, List<ActivityModel>>(() {
  return ActivityListNotifier();
});

// Computed provider for daily progress of selected date
final dailyProgressProvider = Provider<double>((ref) {
  final activitiesState = ref.watch(activityListProvider);
  
  return activitiesState.maybeWhen(
    data: (activities) {
      if (activities.isEmpty) return 0.0;
      final completed = activities.where((a) => a.isCompleted).length;
      return completed / activities.length;
    },
    orElse: () => 0.0,
  );
});

// Provider for daily progress for any given date
final dayProgressProvider = FutureProvider.family<double, DateTime>((ref, date) async {
  final dateString = DateFormat('yyyy-MM-dd').format(date);
  final activities = await ref.read(activityRepositoryProvider).getActivitiesByDate(dateString);
  if (activities.isEmpty) return 0.0;
  final completed = activities.where((a) => a.isCompleted).length;
  return completed / activities.length;
});
