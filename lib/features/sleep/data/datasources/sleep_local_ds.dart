import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../models/sleep_session_model.dart';

abstract class SleepLocalDataSource {
  Future<List<SleepSessionModel>> getSleepSessions();
  Future<SleepSessionModel?> getLatestSleepSession();
  Future<void> saveSleepSession(SleepSessionModel session);
  Future<void> deleteSleepSession(String sessionId);
}

class SleepLocalDataSourceImpl implements SleepLocalDataSource {
  final HiveService _hiveService;

  SleepLocalDataSourceImpl(this._hiveService);

  @override
  Future<List<SleepSessionModel>> getSleepSessions() async {
    try {
      final box = _hiveService.sleepLogsBox;
      final sessions = <SleepSessionModel>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is SleepSessionModel) {
          sessions.add(val);
        }
      }
      // Sort newest start time first
      sessions.sort((a, b) => b.start.compareTo(a.start));
      return sessions;
    } catch (e) {
      throw CacheException('Failed to load sleep sessions: $e');
    }
  }

  @override
  Future<SleepSessionModel?> getLatestSleepSession() async {
    final list = await getSleepSessions();
    if (list.isEmpty) return null;
    return list.first;
  }

  @override
  Future<void> saveSleepSession(SleepSessionModel session) async {
    try {
      final box = _hiveService.sleepLogsBox;
      await box.put(session.id, session);
    } catch (e) {
      throw CacheException('Failed to save sleep session: $e');
    }
  }

  @override
  Future<void> deleteSleepSession(String sessionId) async {
    try {
      final box = _hiveService.sleepLogsBox;
      await box.delete(sessionId);
    } catch (e) {
      throw CacheException('Failed to delete sleep session: $e');
    }
  }
}
