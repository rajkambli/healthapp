import 'package:flutter_test/flutter_test.dart';
import 'package:healthapp/core/errors/exceptions.dart';
import 'package:healthapp/features/dashboard/data/datasources/calories_remote_ds.dart';
import 'package:healthapp/features/dashboard/data/datasources/metrics_local_ds.dart';
import 'package:healthapp/features/dashboard/data/models/calories_data_model.dart';
import 'package:healthapp/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockCaloriesRemoteDataSource extends Mock implements CaloriesRemoteDataSource {}
class MockMetricsLocalDataSource extends Mock implements MetricsLocalDataSource {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockCaloriesRemoteDataSource mockRemoteDataSource;
  late MockMetricsLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockCaloriesRemoteDataSource();
    mockLocalDataSource = MockMetricsLocalDataSource();
    repository = DashboardRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('DashboardRepositoryImpl cache fallback', () {
    final testDate = DateTime(2026, 10, 11);
    final testRemoteModel = CaloriesDataModel(
      totalCalories: 2200,
      activeCalories: 550,
      basalCalories: 1650,
      date: testDate,
      source: 'Remote API',
    );

    final testCachedModel = CaloriesDataModel(
      totalCalories: 2100,
      activeCalories: 450,
      basalCalories: 1650,
      date: testDate,
      source: 'Cached API',
    );

    test('remote fetch success writes to cache and returns isFromCache: false', () async {
      when(() => mockRemoteDataSource.fetchTodayCalories())
          .thenAnswer((_) async => testRemoteModel);
      when(() => mockLocalDataSource.cacheCalories(testRemoteModel))
          .thenAnswer((_) async {});

      final result = await repository.fetchDailyMetrics();

      expect(result.calories.totalCalories, 2200);
      expect(result.isFromCache, isFalse);
      verify(() => mockRemoteDataSource.fetchTodayCalories()).called(1);
      verify(() => mockLocalDataSource.cacheCalories(testRemoteModel)).called(1);
    });

    test('remote fetch failure falls back to cached metrics with isFromCache: true', () async {
      when(() => mockRemoteDataSource.fetchTodayCalories())
          .thenThrow(const ServerException('API Down'));
      when(() => mockLocalDataSource.getCachedCalories())
          .thenAnswer((_) async => testCachedModel);
      when(() => mockLocalDataSource.getLastUpdated())
          .thenAnswer((_) async => testDate);

      final result = await repository.fetchDailyMetrics();

      expect(result.calories.totalCalories, 2100);
      expect(result.isFromCache, isTrue);
      verify(() => mockRemoteDataSource.fetchTodayCalories()).called(1);
      verify(() => mockLocalDataSource.getCachedCalories()).called(1);
    });

    test('remote fetch failure throws exception when cache is empty', () async {
      when(() => mockRemoteDataSource.fetchTodayCalories())
          .thenThrow(const NetworkException('No connection'));
      when(() => mockLocalDataSource.getCachedCalories())
          .thenAnswer((_) async => null);

      expect(
        () => repository.fetchDailyMetrics(),
        throwsA(isA<NetworkException>()),
      );
      verify(() => mockRemoteDataSource.fetchTodayCalories()).called(1);
      verify(() => mockLocalDataSource.getCachedCalories()).called(1);
    });
  });
}
