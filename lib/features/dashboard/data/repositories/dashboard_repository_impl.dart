import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/daily_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/calories_remote_ds.dart';
import '../datasources/metrics_local_ds.dart';
import '../models/calories_data_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final CaloriesRemoteDataSource _remoteDataSource;
  final MetricsLocalDataSource _localDataSource;

  DashboardRepositoryImpl({
    required CaloriesRemoteDataSource remoteDataSource,
    required MetricsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<DailyMetrics?> getCachedDailyMetrics() async {
    try {
      final cachedCalories = await _localDataSource.getCachedCalories();
      if (cachedCalories == null) return null;

      final lastUpdated = await _localDataSource.getLastUpdated() ?? cachedCalories.date;

      return DailyMetrics(
        date: cachedCalories.date,
        calories: cachedCalories.toEntity(),
        lastUpdated: lastUpdated,
        isFromCache: true,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DailyMetrics> fetchDailyMetrics({bool forceRefresh = false}) async {
    try {
      final remoteModel = await _remoteDataSource.fetchTodayCalories();
      
      // Update cache
      await _localDataSource.cacheCalories(remoteModel);
      final lastUpdated = DateTime.now();

      return DailyMetrics(
        date: remoteModel.date,
        calories: remoteModel.toEntity(),
        lastUpdated: lastUpdated,
        isFromCache: false,
      );
    } catch (e) {
      // Offline fallback: check if cached metrics are available
      final cached = await getCachedDailyMetrics();
      if (cached != null) {
        return cached;
      }
      
      // No cache available; rethrow to surface error to BLoC
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to fetch health metrics: $e');
    }
  }

  @override
  Future<void> cacheDailyMetrics(DailyMetrics metrics) async {
    final model = CaloriesDataModel.fromEntity(metrics.calories);
    await _localDataSource.cacheCalories(model);
  }

  @override
  Future<int?> getStepBaseline(DateTime date) async {
    return await _localDataSource.getStepBaseline(date);
  }

  @override
  Future<void> saveStepBaseline(int baseline, DateTime date) async {
    await _localDataSource.saveStepBaseline(baseline, date);
  }
}
