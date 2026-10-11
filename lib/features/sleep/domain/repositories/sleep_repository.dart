import '../entities/sleep_session.dart';

abstract class SleepRepository {
  /// Retrieves all recorded sleep sessions, sorted by start date descending.
  Future<List<SleepSession>> getSleepSessions();

  /// Retrieves the latest sleep session (e.g. for today or most recent).
  Future<SleepSession?> getLatestSleepSession();

  /// Persists a new or updated sleep session.
  Future<void> saveSleepSession(SleepSession session);

  /// Deletes a sleep session by its identifier.
  Future<void> deleteSleepSession(String sessionId);
}
