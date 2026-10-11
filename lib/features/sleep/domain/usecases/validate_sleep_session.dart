import '../entities/sleep_session.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.invalid(this.errorMessage)
      : isValid = false;
}

/// Domain usecase to validate sleep session bounds and segment constraints.
///
/// Rules:
/// 1. Sleep End must be after Sleep Start.
/// 2. Segments must fall within the session [session.start, session.end].
/// 3. Segments must have end after start.
/// 4. Segments must not overlap with one another.
class ValidateSleepSession {
  const ValidateSleepSession();

  ValidationResult call(SleepSession session) {
    // 1. End must be after start
    if (!session.end.isAfter(session.start)) {
      return const ValidationResult.invalid(
        'Sleep end time must be after sleep start time.',
      );
    }

    if (session.segments.isEmpty) {
      return const ValidationResult.valid();
    }

    // 2. Validate individual segment bounds within the session
    for (int i = 0; i < session.segments.length; i++) {
      final seg = session.segments[i];
      if (!seg.end.isAfter(seg.start)) {
        return ValidationResult.invalid(
          'Segment #${i + 1} (${seg.stage.displayName}) end time must be after its start time.',
        );
      }

      if (seg.start.isBefore(session.start) || seg.end.isAfter(session.end)) {
        return ValidationResult.invalid(
          'Segment #${i + 1} (${seg.stage.displayName}) falls outside the sleep session bounds.',
        );
      }
    }

    // 3. Validate no overlapping segments
    final sortedSegments = List.of(session.segments)
      ..sort((a, b) => a.start.compareTo(b.start));

    for (int i = 0; i < sortedSegments.length - 1; i++) {
      final current = sortedSegments[i];
      final next = sortedSegments[i + 1];

      if (current.end.isAfter(next.start)) {
        return ValidationResult.invalid(
          'Segments "${current.stage.displayName}" and "${next.stage.displayName}" overlap in time.',
        );
      }
    }

    return const ValidationResult.valid();
  }
}
