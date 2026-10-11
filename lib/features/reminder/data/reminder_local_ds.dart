import '../../../../core/storage/hive_constants.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/utils/constants.dart';

abstract class ReminderLocalDataSource {
  Future<bool> isReminderEnabled();
  Future<void> setReminderEnabled(bool enabled);
  Future<({int hour, int minute})> getReminderTime();
  Future<void> setReminderTime(int hour, int minute);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final HiveService _hiveService;

  ReminderLocalDataSourceImpl(this._hiveService);

  @override
  Future<bool> isReminderEnabled() async {
    final box = _hiveService.settingsBox;
    final enabled = box.get(HiveConstants.reminderEnabledKey);
    if (enabled is bool) return enabled;
    return false; // Default off until user turns it on
  }

  @override
  Future<void> setReminderEnabled(bool enabled) async {
    final box = _hiveService.settingsBox;
    await box.put(HiveConstants.reminderEnabledKey, enabled);
  }

  @override
  Future<({int hour, int minute})> getReminderTime() async {
    final box = _hiveService.settingsBox;
    final hour = box.get(HiveConstants.reminderHourKey);
    final min = box.get(HiveConstants.reminderMinuteKey);
    return (
      hour: hour is int ? hour : AppConstants.defaultReminderHour,
      minute: min is int ? min : AppConstants.defaultReminderMinute,
    );
  }

  @override
  Future<void> setReminderTime(int hour, int minute) async {
    final box = _hiveService.settingsBox;
    await box.put(HiveConstants.reminderHourKey, hour);
    await box.put(HiveConstants.reminderMinuteKey, minute);
  }
}
