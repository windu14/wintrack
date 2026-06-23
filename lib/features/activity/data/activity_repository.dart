import 'package:wintrack/core/database/db_helper.dart';
import 'package:wintrack/features/activity/domain/activity_model.dart';

class ActivityRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<List<ActivityModel>> getActivitiesByDate(String date) async {
    final maps = await _dbHelper.getActivitiesByDate(date);
    return maps.map((map) => ActivityModel.fromMap(map)).toList();
  }

  Future<ActivityModel> createActivity(ActivityModel activity) async {
    final id = await _dbHelper.insertActivity(activity.toMap());
    return activity.copyWith(id: id);
  }

  Future<void> updateActivity(ActivityModel activity) async {
    await _dbHelper.updateActivity(activity.toMap());
  }

  Future<void> deleteActivity(int id) async {
    await _dbHelper.deleteActivity(id);
  }
}
