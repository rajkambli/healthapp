import 'package:equatable/equatable.dart';
import 'sleep_segment.dart';

class SleepSession extends Equatable {
  final String id;
  final DateTime start;
  final DateTime end;
  final List<SleepSegment> segments;

  const SleepSession({
    required this.id,
    required this.start,
    required this.end,
    this.segments = const [],
  });

  /// Raw duration in bed from session start to session end
  Duration get timeInBed => end.isAfter(start) ? end.difference(start) : Duration.zero;

  @override
  List<Object?> get props => [id, start, end, segments];
}
