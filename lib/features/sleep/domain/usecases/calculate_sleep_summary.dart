import '../entities/sleep_segment.dart';
import '../entities/sleep_session.dart';
import '../entities/sleep_stage.dart';
import '../entities/sleep_summary.dart';

/// Pure use case / calculation domain logic for sleep metrics.
///
/// Formulas:
/// - Total Sleep: (Sleep End - Sleep Start) - Awake Time
/// - Deep Sleep: Sum of (Deep End - Deep Start)
/// - REM Sleep: Sum of (REM End - REM Start)
/// - Light Sleep: Sum of (Light End - Light Start)
/// - Awake Time: Sum of all awake periods during the sleep session
class CalculateSleepSummary {
  const CalculateSleepSummary();

  SleepSummary call(SleepSession session) {
    if (!session.end.isAfter(session.start)) {
      return SleepSummary.empty();
    }

    final Duration timeInBed = session.end.difference(session.start);

    Duration deepDuration = Duration.zero;
    Duration remDuration = Duration.zero;
    Duration lightDuration = Duration.zero;
    Duration awakeDuration = Duration.zero;

    for (final segment in session.segments) {
      final segDuration = _clampedSegmentDuration(segment, session);
      switch (segment.stage) {
        case SleepStage.deep:
          deepDuration += segDuration;
          break;
        case SleepStage.rem:
          remDuration += segDuration;
          break;
        case SleepStage.light:
          lightDuration += segDuration;
          break;
        case SleepStage.awake:
          awakeDuration += segDuration;
          break;
      }
    }

    // Total sleep = timeInBed - awakeDuration
    final int totalSeconds = timeInBed.inSeconds - awakeDuration.inSeconds;
    final Duration totalSleep = Duration(seconds: totalSeconds > 0 ? totalSeconds : 0);

    return SleepSummary(
      total: totalSleep,
      deep: deepDuration,
      rem: remDuration,
      light: lightDuration,
      awake: awakeDuration,
      timeInBed: timeInBed,
    );
  }

  /// Ensures segment duration is within session bounds and not negative
  Duration _clampedSegmentDuration(SleepSegment segment, SleepSession session) {
    if (!segment.end.isAfter(segment.start)) {
      return Duration.zero;
    }

    final effectiveStart = segment.start.isBefore(session.start) ? session.start : segment.start;
    final effectiveEnd = segment.end.isAfter(session.end) ? session.end : segment.end;

    if (effectiveEnd.isAfter(effectiveStart)) {
      return effectiveEnd.difference(effectiveStart);
    }
    return Duration.zero;
  }
}
