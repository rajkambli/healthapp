import 'package:equatable/equatable.dart';
import '../../domain/entities/sleep_session.dart';

sealed class SleepState extends Equatable {
  const SleepState();

  @override
  List<Object?> get props => [];
}

class SleepLoading extends SleepState {
  const SleepLoading();
}

class SleepLoaded extends SleepState {
  final List<SleepSession> sessions;

  const SleepLoaded(this.sessions);

  SleepSession? get latestSession => sessions.isNotEmpty ? sessions.first : null;

  @override
  List<Object?> get props => [sessions];
}

class SleepFailure extends SleepState {
  final String message;
  final List<SleepSession> cachedSessions;

  const SleepFailure(this.message, {this.cachedSessions = const []});

  @override
  List<Object?> get props => [message, cachedSessions];
}
