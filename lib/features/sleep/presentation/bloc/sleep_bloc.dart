import 'package:bloc/bloc.dart';
import '../../domain/entities/sleep_session.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/usecases/validate_sleep_session.dart';
import 'sleep_event.dart';
import 'sleep_state.dart';

class SleepBloc extends Bloc<SleepEvent, SleepState> {
  final SleepRepository _sleepRepository;
  final ValidateSleepSession _validateSleepSession;

  SleepBloc({
    required SleepRepository sleepRepository,
    ValidateSleepSession? validateSleepSession,
  })  : _sleepRepository = sleepRepository,
        _validateSleepSession = validateSleepSession ?? const ValidateSleepSession(),
        super(const SleepLoading()) {
    on<SleepLogsRequested>(_onLogsRequested);
    on<SleepLogAdded>(_onLogAdded);
    on<SleepLogDeleted>(_onLogDeleted);
  }

  Future<void> _onLogsRequested(
    SleepLogsRequested event,
    Emitter<SleepState> emit,
  ) async {
    emit(const SleepLoading());
    try {
      final sessions = await _sleepRepository.getSleepSessions();
      emit(SleepLoaded(sessions));
    } catch (e) {
      emit(SleepFailure('Failed to load sleep sessions: $e'));
    }
  }

  Future<void> _onLogAdded(
    SleepLogAdded event,
    Emitter<SleepState> emit,
  ) async {
    final currentSessions = state is SleepLoaded
        ? (state as SleepLoaded).sessions
        : <SleepSession>[];

    // 1. Domain validation
    final validation = _validateSleepSession(event.session);
    if (!validation.isValid) {
      emit(SleepFailure(
        validation.errorMessage ?? 'Validation failed',
        cachedSessions: currentSessions,
      ));
      return;
    }

    try {
      await _sleepRepository.saveSleepSession(event.session);
      final updatedSessions = await _sleepRepository.getSleepSessions();
      emit(SleepLoaded(updatedSessions));
    } catch (e) {
      emit(SleepFailure(
        'Failed to save sleep log: $e',
        cachedSessions: currentSessions,
      ));
    }
  }

  Future<void> _onLogDeleted(
    SleepLogDeleted event,
    Emitter<SleepState> emit,
  ) async {
    final currentSessions = state is SleepLoaded
        ? (state as SleepLoaded).sessions
        : <SleepSession>[];

    try {
      await _sleepRepository.deleteSleepSession(event.id);
      final updatedSessions = await _sleepRepository.getSleepSessions();
      emit(SleepLoaded(updatedSessions));
    } catch (e) {
      emit(SleepFailure(
        'Failed to delete sleep log: $e',
        cachedSessions: currentSessions,
      ));
    }
  }
}
