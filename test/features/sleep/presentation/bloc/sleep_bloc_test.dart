import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_session.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_stage.dart';
import 'package:healthapp/features/sleep/domain/entities/sleep_segment.dart';
import 'package:healthapp/features/sleep/domain/repositories/sleep_repository.dart';
import 'package:healthapp/features/sleep/domain/usecases/validate_sleep_session.dart';
import 'package:healthapp/features/sleep/presentation/bloc/sleep_bloc.dart';
import 'package:healthapp/features/sleep/presentation/bloc/sleep_event.dart';
import 'package:healthapp/features/sleep/presentation/bloc/sleep_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSleepRepository extends Mock implements SleepRepository {}
class FakeSleepSession extends Fake implements SleepSession {}

void main() {
  late MockSleepRepository mockRepository;
  late ValidateSleepSession validateSleepSession;

  final validSession = SleepSession(
    id: 'session_1',
    start: DateTime(2026, 10, 11, 23, 0),
    end: DateTime(2026, 10, 12, 7, 0),
    segments: [
      SleepSegment(
        id: 's1',
        stage: SleepStage.deep,
        start: DateTime(2026, 10, 11, 23, 30),
        end: DateTime(2026, 10, 12, 1, 30),
      ),
    ],
  );

  final invalidSession = SleepSession(
    id: 'invalid_1',
    start: DateTime(2026, 10, 12, 8, 0),
    end: DateTime(2026, 10, 12, 7, 0), // End before start
  );

  setUpAll(() {
    registerFallbackValue(FakeSleepSession());
  });

  setUp(() {
    mockRepository = MockSleepRepository();
    validateSleepSession = const ValidateSleepSession();
  });

  group('SleepBloc', () {
    blocTest<SleepBloc, SleepState>(
      'SleepLogsRequested loads sessions and emits SleepLoaded',
      build: () {
        when(() => mockRepository.getSleepSessions())
            .thenAnswer((_) async => [validSession]);
        return SleepBloc(
          sleepRepository: mockRepository,
          validateSleepSession: validateSleepSession,
        );
      },
      act: (bloc) => bloc.add(const SleepLogsRequested()),
      expect: () => [
        const SleepLoading(),
        SleepLoaded([validSession]),
      ],
    );

    blocTest<SleepBloc, SleepState>(
      'SleepLogAdded with valid session persists and emits updated SleepLoaded',
      build: () {
        when(() => mockRepository.saveSleepSession(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getSleepSessions())
            .thenAnswer((_) async => [validSession]);
        return SleepBloc(
          sleepRepository: mockRepository,
          validateSleepSession: validateSleepSession,
        );
      },
      act: (bloc) => bloc.add(SleepLogAdded(validSession)),
      expect: () => [
        SleepLoaded([validSession]),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSleepSession(validSession)).called(1);
      },
    );

    blocTest<SleepBloc, SleepState>(
      'SleepLogAdded with invalid session emits SleepFailure without calling repository',
      build: () {
        return SleepBloc(
          sleepRepository: mockRepository,
          validateSleepSession: validateSleepSession,
        );
      },
      act: (bloc) => bloc.add(SleepLogAdded(invalidSession)),
      expect: () => [
        isA<SleepFailure>().having(
          (s) => s.message,
          'message',
          contains('must be after sleep start'),
        ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.saveSleepSession(any()));
      },
    );

    blocTest<SleepBloc, SleepState>(
      'SleepLogDeleted deletes session and emits updated list',
      build: () {
        when(() => mockRepository.deleteSleepSession(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getSleepSessions())
            .thenAnswer((_) async => []);
        return SleepBloc(
          sleepRepository: mockRepository,
          validateSleepSession: validateSleepSession,
        );
      },
      seed: () => SleepLoaded([validSession]),
      act: (bloc) => bloc.add(const SleepLogDeleted('session_1')),
      expect: () => [
        const SleepLoaded([]),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteSleepSession('session_1')).called(1);
      },
    );
  });
}
