import '../../domain/entities/sleep_session.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../datasources/sleep_local_ds.dart';
import '../models/sleep_session_model.dart';

class SleepRepositoryImpl implements SleepRepository {
  final SleepLocalDataSource _localDataSource;

  SleepRepositoryImpl({required SleepLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<SleepSession>> getSleepSessions() async {
    final models = await _localDataSource.getSleepSessions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<SleepSession?> getLatestSleepSession() async {
    final model = await _localDataSource.getLatestSleepSession();
    return model?.toEntity();
  }

  @override
  Future<void> saveSleepSession(SleepSession session) async {
    final model = SleepSessionModel.fromEntity(session);
    await _localDataSource.saveSleepSession(model);
  }

  @override
  Future<void> deleteSleepSession(String sessionId) async {
    await _localDataSource.deleteSleepSession(sessionId);
  }
}
