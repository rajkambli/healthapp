import '../entities/daily_metrics.dart';

abstract class DashboardRepository {
  /// Loads the cached daily metrics from local storage if available.
  Future<DailyMetrics?> getCachedDailyMetrics();

  /// Fetches daily metrics from the remote API (or mock fallback) and updates cache on success.
  /// If forceRefresh is false, can return cache first or perform network fetch.
  Future<DailyMetrics> fetchDailyMetrics({bool forceRefresh = false});

  /// Persists metrics to local cache.
  Future<void> cacheDailyMetrics(DailyMetrics metrics);

  /// Retrieves the recorded steps baseline for a given date.
  Future<int?> getStepBaseline(DateTime date);

  /// Persists the steps baseline for a given date.
  Future<void> saveStepBaseline(int baseline, DateTime date);
}
