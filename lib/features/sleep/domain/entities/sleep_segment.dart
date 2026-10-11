import 'package:equatable/equatable.dart';
import 'sleep_stage.dart';

class SleepSegment extends Equatable {
  final String id;
  final SleepStage stage;
  final DateTime start;
  final DateTime end;

  const SleepSegment({
    required this.id,
    required this.stage,
    required this.start,
    required this.end,
  });

  Duration get duration => end.isAfter(start) ? end.difference(start) : Duration.zero;

  @override
  List<Object?> get props => [id, stage, start, end];
}
