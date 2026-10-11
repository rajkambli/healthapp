import 'package:flutter_test/flutter_test.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_segment.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_session.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_stage.dart';
import 'package:healthapp/features/sleep/domain/usecases/calculate_sleep_summary.dart';

void main() {
  late CalculateSleepSummary calculator;

  setUp(() {
    calculator = const CalculateSleepSummary();
  });

  group('CalculateSleepSummary', () {
    test('normal session calculates total, stages, and awake correctly', () {
      final start = DateTime(2026, 10, 11, 22, 0);
      final end = DateTime(2026, 10, 12, 6, 0); // 8 hours in bed

      final session = SleepSession(
        id: '1',
        start: start,
        end: end,
        segments: [
          SleepSegment(
            id: 's1',
            stage: SleepStage.light,
            start: DateTime(2026, 10, 11, 22, 0),
            end: DateTime(2026, 10, 11, 23, 30), // 1h 30m
          ),
          SleepSegment(
            id: 's2',
            stage: SleepStage.deep,
            start: DateTime(2026, 10, 11, 23, 30),
            end: DateTime(2026, 10, 12, 1, 30), // 2h 00m
          ),
          SleepSegment(
            id: 's3',
            stage: SleepStage.awake,
            start: DateTime(2026, 10, 12, 1, 30),
            end: DateTime(2026, 10, 12, 2, 0), // 30m awake
          ),
          SleepSegment(
            id: 's4',
            stage: SleepStage.rem,
            start: DateTime(2026, 10, 12, 2, 0),
            end: DateTime(2026, 10, 12, 4, 0), // 2h 00m
          ),
          SleepSegment(
            id: 's5',
            stage: SleepStage.light,
            start: DateTime(2026, 10, 12, 4, 0),
            end: DateTime(2026, 10, 12, 6, 0), // 2h 00m
          ),
        ],
      );

      final summary = calculator(session);

      expect(summary.timeInBed, const Duration(hours: 8));
      expect(summary.awake, const Duration(minutes: 30));
      // Total sleep = 8h - 30m = 7h 30m
      expect(summary.total, const Duration(hours: 7, minutes: 30));
      expect(summary.deep, const Duration(hours: 2));
      expect(summary.rem, const Duration(hours: 2));
      expect(summary.light, const Duration(hours: 3, minutes: 30));
      expect(summary.efficiencyPercentage, (450 / 480) * 100);
    });

    test('session crossing midnight computes duration across day boundaries', () {
      final start = DateTime(2026, 10, 11, 23, 15);
      final end = DateTime(2026, 10, 12, 7, 15); // 8 hours

      final session = SleepSession(
        id: 'midnight_1',
        start: start,
        end: end,
        segments: [
          SleepSegment(
            id: 's1',
            stage: SleepStage.deep,
            start: DateTime(2026, 10, 11, 23, 30),
            end: DateTime(2026, 10, 12, 1, 30), // 2 hours crossing midnight
          ),
        ],
      );

      final summary = calculator(session);

      expect(summary.timeInBed, const Duration(hours: 8));
      expect(summary.deep, const Duration(hours: 2));
      expect(summary.awake, Duration.zero);
      expect(summary.total, const Duration(hours: 8));
    });

    test('session with no awake time has total sleep equal to time in bed', () {
      final start = DateTime(2026, 10, 11, 22, 0);
      final end = DateTime(2026, 10, 12, 5, 0); // 7 hours

      final session = SleepSession(
        id: 'no_awake',
        start: start,
        end: end,
        segments: [
          SleepSegment(
            id: 's1',
            stage: SleepStage.light,
            start: DateTime(2026, 10, 11, 22, 0),
            end: DateTime(2026, 10, 12, 1, 0),
          ),
          SleepSegment(
            id: 's2',
            stage: SleepStage.deep,
            start: DateTime(2026, 10, 12, 1, 0),
            end: DateTime(2026, 10, 12, 5, 0),
          ),
        ],
      );

      final summary = calculator(session);

      expect(summary.awake, Duration.zero);
      expect(summary.total, const Duration(hours: 7));
      expect(summary.efficiencyPercentage, 100.0);
    });

    test('session with empty stages treats entire session as total sleep', () {
      final start = DateTime(2026, 10, 11, 23, 0);
      final end = DateTime(2026, 10, 12, 6, 30); // 7h 30m

      final session = SleepSession(
        id: 'empty_stages',
        start: start,
        end: end,
        segments: const [],
      );

      final summary = calculator(session);

      expect(summary.timeInBed, const Duration(hours: 7, minutes: 30));
      expect(summary.total, const Duration(hours: 7, minutes: 30));
      expect(summary.deep, Duration.zero);
      expect(summary.rem, Duration.zero);
      expect(summary.light, Duration.zero);
      expect(summary.awake, Duration.zero);
    });

    test('multiple segments of the same stage are summed together', () {
      final start = DateTime(2026, 10, 11, 22, 0);
      final end = DateTime(2026, 10, 12, 6, 0);

      final session = SleepSession(
        id: 'multi_same_stage',
        start: start,
        end: end,
        segments: [
          SleepSegment(
            id: 'deep_1',
            stage: SleepStage.deep,
            start: DateTime(2026, 10, 11, 22, 30),
            end: DateTime(2026, 10, 11, 23, 30), // 1 hour
          ),
          SleepSegment(
            id: 'deep_2',
            stage: SleepStage.deep,
            start: DateTime(2026, 10, 12, 2, 0),
            end: DateTime(2026, 10, 12, 3, 30), // 1.5 hours
          ),
          SleepSegment(
            id: 'awake_1',
            stage: SleepStage.awake,
            start: DateTime(2026, 10, 12, 0, 0),
            end: DateTime(2026, 10, 12, 0, 15), // 15 mins
          ),
          SleepSegment(
            id: 'awake_2',
            stage: SleepStage.awake,
            start: DateTime(2026, 10, 12, 4, 0),
            end: DateTime(2026, 10, 12, 4, 15), // 15 mins
          ),
        ],
      );

      final summary = calculator(session);

      expect(summary.deep, const Duration(hours: 2, minutes: 30));
      expect(summary.awake, const Duration(minutes: 30));
      expect(summary.total, const Duration(hours: 7, minutes: 30));
    });
  });
}
