/// Constant keys and box names for Hive local storage.
class HiveConstants {
  HiveConstants._();

  // Box Names
  static const String metricsCacheBox = 'metrics_cache';
  static const String sleepLogsBox = 'sleep_logs';
  static const String settingsBox = 'settings';

  // Settings Keys
  static const String stepBaselineKey = 'step_baseline_value';
  static const String stepBaselineDateKey = 'step_baseline_date';
  static const String reminderEnabledKey = 'reminder_enabled';
  static const String reminderHourKey = 'reminder_hour';
  static const String reminderMinuteKey = 'reminder_minute';

  // Metrics Cache Keys
  static const String latestCaloriesKey = 'latest_calories';
  static const String latestMetricsKey = 'latest_metrics';

  // Adapter Type IDs
  static const int caloriesDataTypeId = 0;
  static const int sleepStageTypeId = 1;
  static const int sleepSegmentTypeId = 2;
  static const int sleepSessionTypeId = 3;
}
