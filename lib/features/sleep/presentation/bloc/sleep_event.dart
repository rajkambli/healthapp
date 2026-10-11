import 'package:equatable/equatable.dart';
import '../../domain/entities/sleep_session.dart';

sealed class SleepEvent extends Equatable {
  const SleepEvent();

  @override
  List<Object?> get props => [];
}

class SleepLogsRequested extends SleepEvent {
  const SleepLogsRequested();
}

class SleepLogAdded extends SleepEvent {
  final SleepSession session;

  const SleepLogAdded(this.session);

  @override
  List<Object?> get props => [session];
}

class SleepLogDeleted extends SleepEvent {
  final String id;

  const SleepLogDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
