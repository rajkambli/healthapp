import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/hive_constants.dart';
import '../../../../core/storage/hive_service.dart';
import '../models/calories_data_model.dart';

abstract class MetricsLocalDataSource {
  Future<CaloriesDataModel?> getCachedCalories();
  Future<void> cacheCalories(CaloriesDataModel model);
  Future<DateTime?> getLastUpdated();
  Future<int?> getStepBaseline(DateTime date);
  Future<void> saveStepBaseline(int baseline, DateTime date);
}

class MetricsLocalDataSourceImpl implements MetricsLocalDataSource {
  final HiveService _hiveService;

  MetricsLocalDataSourceImpl(this._hiveService);

  @override
  Future<CaloriesDataModel?> getCachedCalories() async {
    try {
      final box = _hiveService.metricsCacheBox;
      final cached = box.get(HiveConstants.latestCaloriesKey);
      if (cached is CaloriesDataModel) {
        return cached;
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read cached calories: $e');
    }
  }

  @override
  Future<void> cacheCalories(CaloriesDataModel model) async {
    try {
      final box = _hiveService.metricsCacheBox;
      await box.put(HiveConstants.latestCaloriesKey, model);
      await box.put(
        '${HiveConstants.latestCaloriesKey}_timestamp',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException('Failed to save calories to cache: $e');
    }
  }

  @override
  Future<DateTime?> getLastUpdated() async {
    try {
      final box = _hiveService.metricsCacheBox;
      final tsStr = box.get('${HiveConstants.latestCaloriesKey}_timestamp');
      if (tsStr is String) {
        return DateTime.tryParse(tsStr);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read last updated time: $e');
    }
  }

  @override
  Future<int?> getStepBaseline(DateTime date) async {
    try {
      final box = _hiveService.settingsBox;
      final savedDateStr = box.get(HiveConstants.stepBaselineDateKey);
      if (savedDateStr is String) {
        final savedDate = DateTime.tryParse(savedDateStr);
        if (savedDate != null &&
            savedDate.year == date.year &&
            savedDate.month == date.month &&
            savedDate.day == date.day) {
          final baseline = box.get(HiveConstants.stepBaselineKey);
          if (baseline is int) {
            return baseline;
          }
        }
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read step baseline: $e');
    }
  }

  @override
  Future<void> saveStepBaseline(int baseline, DateTime date) async {
    try {
      final box = _hiveService.settingsBox;
      await box.put(HiveConstants.stepBaselineKey, baseline);
      await box.put(HiveConstants.stepBaselineDateKey, date.toIso8601String());
    } catch (e) {
      throw CacheException('Failed to save step baseline: $e');
    }
  }
}
