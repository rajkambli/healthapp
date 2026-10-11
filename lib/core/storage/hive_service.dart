import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../../hive_registrar.g.dart';
import 'hive_constants.dart';

class HiveService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initializes Hive, registers generated type adapters, and opens application boxes.
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    Hive.registerAdapters();

    // Open boxes
    await Hive.openBox(HiveConstants.metricsCacheBox);
    await Hive.openBox(HiveConstants.sleepLogsBox);
    await Hive.openBox(HiveConstants.settingsBox);

    _isInitialized = true;
    debugPrint('HiveService: Initialized successfully and opened boxes.');
  }

  Box get metricsCacheBox => Hive.box(HiveConstants.metricsCacheBox);
  Box get sleepLogsBox => Hive.box(HiveConstants.sleepLogsBox);
  Box get settingsBox => Hive.box(HiveConstants.settingsBox);

  /// Clears all boxes (useful for testing or cache reset)
  Future<void> clearAllBoxes() async {
    await metricsCacheBox.clear();
    await sleepLogsBox.clear();
    await settingsBox.clear();
  }
}
