import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/utils/constants.dart';

abstract class NotificationService {
  Future<void> init({void Function(String? payload)? onSelectNotification});
  Future<bool> requestPermissions();
  Future<void> scheduleDailySleepReminder({required int hour, required int minute});
  Future<void> cancelSleepReminder();
}

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  NotificationServiceImpl({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> init({void Function(String? payload)? onSelectNotification}) async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      debugPrint('NotificationService: fallback to local UTC location: $e');
      tz.setLocalLocation(tz.local);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onSelectNotification?.call(response.payload);
      },
    );

    _isInitialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    bool? granted = false;

    // Android 13+ permission request
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      granted = await androidImpl.requestNotificationsPermission();
    }

    // iOS / macOS permission request
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return granted ?? false;
  }

  @override
  Future<void> scheduleDailySleepReminder({
    required int hour,
    required int minute,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      id: AppConstants.sleepReminderNotificationId,
      title: 'Log Your Sleep',
      body: 'Track your nightly rest to keep your daily health dashboard updated!',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'sleep_log',
    );

    debugPrint('Scheduled daily sleep reminder for $hour:${minute.toString().padLeft(2, '0')}');
  }

  @override
  Future<void> cancelSleepReminder() async {
    await _plugin.cancel(id: AppConstants.sleepReminderNotificationId);
    debugPrint('Cancelled sleep reminder notification.');
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
