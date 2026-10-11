class AppConstants {
  AppConstants._();

  static const String appTitle = 'Health Dashboard';

  // Calories API default configuration
  // The API key is injected at compile time via --dart-define=CALORIES_API_KEY=...
  static const String caloriesApiKey = String.fromEnvironment('CALORIES_API_KEY', defaultValue: '');

  // API Ninjas endpoint for calories burned
  static const String apiNinjasCaloriesUrl = 'https://api.api-ninjas.com/v1/caloriesburned';

  // Default targets / goals
  static const int defaultDailyStepGoal = 10000;
  static const int defaultDailyCaloriesGoal = 2200;
  static const int defaultDailySleepMinutesGoal = 480; // 8 hours

  // Default reminder time (9:00 AM)
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;

  // Notification details
  static const String notificationChannelId = 'health_reminders_channel';
  static const String notificationChannelName = 'Health Reminders';
  static const String notificationChannelDesc = 'Daily reminders to log your sleep and view metrics';
  static const int sleepReminderNotificationId = 101;
}
