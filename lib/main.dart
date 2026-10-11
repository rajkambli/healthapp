import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/reminder/data/notification_service.dart';
import 'features/sleep/presentation/pages/sleep_log_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive, Dio, Data Sources, Repositories and Blocs
  await configureDependencies();

  // Initialize notification service with deep-link navigation handler
  final notificationService = sl<NotificationService>();
  await notificationService.init(
    onSelectNotification: (payload) {
      if (payload == 'sleep_log') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const SleepLogPage()),
        );
      }
    },
  );

  runApp(const HealthApp());
}
