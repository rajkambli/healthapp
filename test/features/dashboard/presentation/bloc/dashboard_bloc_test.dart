import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthapp/core/errors/exceptions.dart';
import 'package:healthapp/features/dashboard/domain/entities/calories_data.dart';
import 'package:healthapp/features/dashboard/domain/entities/daily_metrics.dart';
import 'package:healthapp/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:healthapp/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:healthapp/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:healthapp/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockRepository;

  final testDate = DateTime(2026, 10, 11);
  final testCalories = CaloriesData(
    totalCalories: 2300,
    activeCalories: 600,
    basalCalories: 1700,
    date: testDate,
    source: 'Test API',
  );

  final testMetrics = DailyMetrics(
    date: testDate,
    calories: testCalories,
    lastUpdated: testDate,
    isFromCache: false,
  );

  final cachedMetrics = DailyMetrics(
    date: testDate,
    calories: testCalories,
    lastUpdated: testDate,
    isFromCache: true,
  );

  setUp(() {
    mockRepository = MockDashboardRepository();
  });

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'DashboardStarted emits [loading, success] when no cache and API succeeds',
      build: () {
        when(() => mockRepository.getCachedDailyMetrics())
            .thenAnswer((_) async => null);
        when(() => mockRepository.fetchDailyMetrics(forceRefresh: true))
            .thenAnswer((_) async => testMetrics);
        return DashboardBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const DashboardStarted()),
      expect: () => [
        const DashboardState(status: DashboardStatus.loading),
        DashboardState(
          status: DashboardStatus.success,
          calories: testCalories,
          lastUpdated: testDate,
          isOffline: false,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.getCachedDailyMetrics()).called(1);
        verify(() => mockRepository.fetchDailyMetrics(forceRefresh: true)).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'DashboardStarted emits [success(cached), success(remote)] when cache exists and API succeeds',
      build: () {
        when(() => mockRepository.getCachedDailyMetrics())
            .thenAnswer((_) async => cachedMetrics);
        when(() => mockRepository.fetchDailyMetrics(forceRefresh: true))
            .thenAnswer((_) async => testMetrics);
        return DashboardBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const DashboardStarted()),
      expect: () => [
        DashboardState(
          status: DashboardStatus.success,
          calories: testCalories,
          lastUpdated: testDate,
          isOffline: true,
        ),
        DashboardState(
          status: DashboardStatus.success,
          calories: testCalories,
          lastUpdated: testDate,
          isOffline: false,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'DashboardStarted emits [success(cached)] with isOffline: true when API fails and cache exists',
      build: () {
        when(() => mockRepository.getCachedDailyMetrics())
            .thenAnswer((_) async => cachedMetrics);
        when(() => mockRepository.fetchDailyMetrics(forceRefresh: true))
            .thenThrow(const NetworkException('No connection'));
        return DashboardBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const DashboardStarted()),
      expect: () => [
        DashboardState(
          status: DashboardStatus.success,
          calories: testCalories,
          lastUpdated: testDate,
          isOffline: true,
        ),
        DashboardState(
          status: DashboardStatus.success,
          calories: testCalories,
          lastUpdated: testDate,
          isOffline: true,
          errorMessage: 'No connection',
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'DashboardStarted emits [loading, failure] when API fails and NO cache exists',
      build: () {
        when(() => mockRepository.getCachedDailyMetrics())
            .thenAnswer((_) async => null);
        when(() => mockRepository.fetchDailyMetrics(forceRefresh: true))
            .thenThrow(const ServerException('Server error'));
        return DashboardBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const DashboardStarted()),
      expect: () => [
        const DashboardState(status: DashboardStatus.loading),
        const DashboardState(
          status: DashboardStatus.failure,
          errorMessage: 'Server error',
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'DashboardRefreshed updates data without resetting state to loading',
      build: () {
        when(() => mockRepository.fetchDailyMetrics(forceRefresh: true))
            .thenAnswer((_) async => testMetrics);
        return DashboardBloc(repository: mockRepository);
      },
      seed: () => DashboardState(
        status: DashboardStatus.success,
        calories: testCalories,
        isOffline: true,
      ),
      act: (bloc) => bloc.add(const DashboardRefreshed()),
      expect: () => [
        DashboardState(
          status: DashboardStatus.success,
          calories: testCalories,
          lastUpdated: testDate,
          isOffline: false,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'DashboardRetried transitions from failure to loading and then success',
      build: () {
        when(() => mockRepository.fetchDailyMetrics(forceRefresh: true))
            .thenAnswer((_) async => testMetrics);
        return DashboardBloc(repository: mockRepository);
      },
      seed: () => const DashboardState(
        status: DashboardStatus.failure,
        errorMessage: 'Initial error',
      ),
      act: (bloc) => bloc.add(const DashboardRetried()),
      expect: () => [
        const DashboardState(
          status: DashboardStatus.loading,
          errorMessage: null,
        ),
        DashboardState(
          status: DashboardStatus.success,
          calories: testCalories,
          lastUpdated: testDate,
          isOffline: false,
        ),
      ],
    );
  });
}
