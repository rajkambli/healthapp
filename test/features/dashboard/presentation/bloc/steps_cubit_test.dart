import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthapp/features/dashboard/data/datasources/steps_ds.dart';
import 'package:healthapp/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:healthapp/features/dashboard/presentation/bloc/steps_cubit.dart';
import 'package:healthapp/features/dashboard/presentation/bloc/steps_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

class MockStepsDataSource extends Mock implements StepsDataSource {}
class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockStepsDataSource mockStepsDataSource;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockStepsDataSource = MockStepsDataSource();
    mockRepository = MockDashboardRepository();
  });

  group('StepsCubit', () {
    blocTest<StepsCubit, StepsState>(
      'emits StepsPermissionDenied when activity recognition is denied',
      build: () {
        when(() => mockStepsDataSource.checkPermission())
            .thenAnswer((_) async => PermissionStatus.denied);
        return StepsCubit(
          stepsDataSource: mockStepsDataSource,
          repository: mockRepository,
        );
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        const StepsPermissionDenied(isPermanentlyDenied: false),
      ],
    );

    blocTest<StepsCubit, StepsState>(
      'emits StepsPermissionDenied with permanentlyDenied flag when permanently denied',
      build: () {
        when(() => mockStepsDataSource.requestPermission())
            .thenAnswer((_) async => PermissionStatus.permanentlyDenied);
        return StepsCubit(
          stepsDataSource: mockStepsDataSource,
          repository: mockRepository,
        );
      },
      act: (cubit) => cubit.requestPermission(),
      expect: () => [
        const StepsPermissionDenied(isPermanentlyDenied: true),
      ],
    );

    test('baseline reset on a new day resets baseline and calculates today steps from 0', () async {
      final cubit = StepsCubit(
        stepsDataSource: mockStepsDataSource,
        repository: mockRepository,
      );

      final day1 = DateTime(2026, 10, 11);
      final day2 = DateTime(2026, 10, 12);

      // Day 1 setup: no baseline exists for Day 1
      when(() => mockRepository.getStepBaseline(day1))
          .thenAnswer((_) async => null);
      when(() => mockRepository.saveStepBaseline(5000, day1))
          .thenAnswer((_) async {});

      // First reading on Day 1: boot count is 5000 -> baseline becomes 5000, todaySteps = 0
      await cubit.handleStepReadingForTesting(5000, date: day1);
      expect(cubit.state, const StepsLoaded(todaySteps: 0, rawReading: 5000));

      // Second reading on Day 1: boot count is 5850 -> todaySteps = 5850 - 5000 = 850
      await cubit.handleStepReadingForTesting(5850, date: day1);
      expect(cubit.state, const StepsLoaded(todaySteps: 850, rawReading: 5850));

      // Day 2 transition: no baseline exists for Day 2 yet
      when(() => mockRepository.getStepBaseline(day2))
          .thenAnswer((_) async => null);
      when(() => mockRepository.saveStepBaseline(6000, day2))
          .thenAnswer((_) async {});

      // First reading on Day 2: boot count is 6000 -> new baseline 6000, todaySteps = 0
      await cubit.handleStepReadingForTesting(6000, date: day2);
      expect(cubit.state, const StepsLoaded(todaySteps: 0, rawReading: 6000));

      // Further reading on Day 2: boot count is 7200 -> todaySteps = 1200
      await cubit.handleStepReadingForTesting(7200, date: day2);
      expect(cubit.state, const StepsLoaded(todaySteps: 1200, rawReading: 7200));

      await cubit.close();
    });

    test('reboot detection: when current reading is below baseline, baseline resets', () async {
      final cubit = StepsCubit(
        stepsDataSource: mockStepsDataSource,
        repository: mockRepository,
      );

      final today = DateTime(2026, 10, 11);

      // Baseline in Hive is 10000
      when(() => mockRepository.getStepBaseline(today))
          .thenAnswer((_) async => 10000);
      when(() => mockRepository.saveStepBaseline(150, today))
          .thenAnswer((_) async {});

      // Device rebooted! Raw reading drops to 150 (which is < 10000)
      await cubit.handleStepReadingForTesting(150, date: today);

      // Baseline should reset to 150 and todaySteps emitted as 0
      expect(cubit.state, const StepsLoaded(todaySteps: 0, rawReading: 150));
      verify(() => mockRepository.saveStepBaseline(150, today)).called(1);

      await cubit.close();
    });
  });
}
