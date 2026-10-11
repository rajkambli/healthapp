import 'package:flutter_test/flutter_test.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_segment.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_session.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_stage.dart';
import 'package:healthapp/features/sleep/domain/usecases/validate_sleep_session.dart';

void main() {
  late ValidateSleepSession validator;

  setUp(() {
    validator = const ValidateSleepSession();
  });

  group('ValidateSleepSession', () {
    test('fails when end is before or same as start', () {
      final start = DateTime(2026, 10, 11, 23, 0);
      final end = DateTime(2026, 10, 11, 22, 0); // Before start!

      final session = SleepSession(
        id: '1',
        start: start,
        end: end,
      );

      final result = validator(session);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('must be after sleep start'));
    });

    test('fails when a segment falls outside the session bounds', () {
      final start = DateTime(2026, 10, 11, 22, 0);
      final end = DateTime(2026, 10, 12, 6, 0);

      final session = SleepSession(
        id: '2',
        start: start,
        end: end,
        segments: [
          SleepSegment(
            id: 'seg_outside',
            stage: SleepStage.deep,
            start: DateTime(2026, 10, 11, 21, 30), // 30 mins before session start!
            end: DateTime(2026, 10, 11, 23, 0),
          ),
        ],
      );

      final result = validator(session);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('falls outside the sleep session'));
    });

    test('fails when segments overlap with each other', () {
      final start = DateTime(2026, 10, 11, 22, 0);
      final end = DateTime(2026, 10, 12, 6, 0);

      final session = SleepSession(
        id: '3',
        start: start,
        end: end,
        segments: [
          SleepSegment(
            id: 'seg_1',
            stage: SleepStage.deep,
            start: DateTime(2026, 10, 11, 23, 0),
            end: DateTime(2026, 10, 12, 1, 0), // Ends at 1:00 AM
          ),
          SleepSegment(
            id: 'seg_2',
            stage: SleepStage.rem,
            start: DateTime(2026, 10, 12, 0, 30), // Starts at 0:30 AM (overlap!)
            end: DateTime(2026, 10, 12, 2, 0),
          ),
        ],
      );

      final result = validator(session);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('overlap in time'));
    });

    test('passes when valid session has non-overlapping bounded segments', () {
      final start = DateTime(2026, 10, 11, 22, 0);
      final end = DateTime(2026, 10, 12, 6, 0);

      final session = SleepSession(
        id: 'valid',
        start: start,
        end: end,
        segments: [
          SleepSegment(
            id: 's1',
            stage: SleepStage.light,
            start: DateTime(2026, 10, 11, 22, 0),
            end: DateTime(2026, 10, 11, 23, 30),
          ),
          SleepSegment(
            id: 's2',
            stage: SleepStage.deep,
            start: DateTime(2026, 10, 11, 23, 30),
            end: DateTime(2026, 10, 12, 1, 30),
          ),
          SleepSegment(
            id: 's3',
            stage: SleepStage.rem,
            start: DateTime(2026, 10, 12, 1, 30),
            end: DateTime(2026, 10, 12, 4, 0),
          ),
        ],
      );

      final result = validator(session);
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });
  });
}
