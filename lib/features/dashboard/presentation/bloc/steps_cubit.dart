import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/datasources/steps_ds.dart';
import 'steps_state.dart';

class StepsCubit extends Cubit<StepsState> {
  final StepsDataSource _stepsDataSource;
  final DashboardRepository _repository;
  StreamSubscription<int>? _subscription;

  int? _baseline;
  DateTime? _baselineDate;

  StepsCubit({
    required StepsDataSource stepsDataSource,
    required DashboardRepository repository,
  })  : _stepsDataSource = stepsDataSource,
        _repository = repository,
        super(const StepsInitial());

  /// Checks permission and initializes pedometer stream if granted
  Future<void> init() async {
    final status = await _stepsDataSource.checkPermission();
    if (status.isGranted || status.isLimited) {
      _subscribeToPedometer();
    } else {
      emit(StepsPermissionDenied(isPermanentlyDenied: status.isPermanentlyDenied));
    }
  }

  /// Requests activity recognition permission and subscribes if granted
  Future<void> requestPermission() async {
    final status = await _stepsDataSource.requestPermission();
    if (status.isGranted || status.isLimited) {
      _subscribeToPedometer();
    } else if (status.isPermanentlyDenied) {
      emit(const StepsPermissionDenied(isPermanentlyDenied: true));
    } else {
      emit(const StepsPermissionDenied(isPermanentlyDenied: false));
    }
  }

  Future<void> openAppSettings() async {
    await _stepsDataSource.openSettings();
  }

  void _subscribeToPedometer() {
    _subscription?.cancel();
    _subscription = _stepsDataSource.stepCountStream.listen(
      (rawReading) => _handleStepReading(rawReading),
      onError: (error) {
        emit(StepsUnavailable(
          'Pedometer sensor unavailable: ${error.toString()}',
        ));
      },
      cancelOnError: false,
    );
  }

  /// Processes raw pedometer readings and computes today's steps using daily baseline
  Future<void> _handleStepReading(int rawReading, {DateTime? now}) async {
    final today = now ?? DateTime.now();

    // 1. If baseline is not in memory, try loading from storage
    if (_baseline == null || _baselineDate == null || !_isSameDay(_baselineDate!, today)) {
      _baseline = await _repository.getStepBaseline(today);
      _baselineDate = today;
    }

    // 2. If no baseline stored for today: set baseline to current reading
    if (_baseline == null) {
      _baseline = rawReading;
      _baselineDate = today;
      await _repository.saveStepBaseline(_baseline!, today);
      emit(StepsLoaded(todaySteps: 0, rawReading: rawReading));
      return;
    }

    // 3. If reading is less than baseline: device rebooted! Reset baseline to current reading
    if (rawReading < _baseline!) {
      _baseline = rawReading;
      _baselineDate = today;
      await _repository.saveStepBaseline(_baseline!, today);
      emit(StepsLoaded(todaySteps: 0, rawReading: rawReading));
      return;
    }

    // 4. Normal case: today's steps = rawReading - baseline
    final todaySteps = rawReading - _baseline!;
    emit(StepsLoaded(todaySteps: todaySteps, rawReading: rawReading));
  }

  /// Visible for testing to verify baseline reset on new day or reboot
  Future<void> handleStepReadingForTesting(int rawReading, {required DateTime date}) async {
    await _handleStepReading(rawReading, now: date);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
