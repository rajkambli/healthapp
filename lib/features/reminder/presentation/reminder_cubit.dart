import 'package:bloc/bloc.dart';
import '../data/notification_service.dart';
import '../data/reminder_local_ds.dart';
import 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final NotificationService _notificationService;
  final ReminderLocalDataSource _localDataSource;

  ReminderCubit({
    required NotificationService notificationService,
    required ReminderLocalDataSource localDataSource,
  })  : _notificationService = notificationService,
        _localDataSource = localDataSource,
        super(const ReminderState());

  Future<void> init() async {
    final enabled = await _localDataSource.isReminderEnabled();
    final time = await _localDataSource.getReminderTime();

    emit(
      state.copyWith(
        isEnabled: enabled,
        hour: time.hour,
        minute: time.minute,
      ),
    );

    if (enabled) {
      await _notificationService.scheduleDailySleepReminder(
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> toggleReminder(bool enabled) async {
    if (enabled) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        emit(
          state.copyWith(
            isEnabled: false,
            isPermissionGranted: false,
            errorMessage: 'Notification permission was denied in device settings.',
          ),
        );
        return;
      }

      await _localDataSource.setReminderEnabled(true);
      await _notificationService.scheduleDailySleepReminder(
        hour: state.hour,
        minute: state.minute,
      );

      emit(
        state.copyWith(
          isEnabled: true,
          isPermissionGranted: true,
          errorMessage: null,
        ),
      );
    } else {
      await _localDataSource.setReminderEnabled(false);
      await _notificationService.cancelSleepReminder();

      emit(
        state.copyWith(
          isEnabled: false,
          errorMessage: null,
        ),
      );
    }
  }

  Future<void> updateTime(int hour, int minute) async {
    await _localDataSource.setReminderTime(hour, minute);

    if (state.isEnabled) {
      await _notificationService.scheduleDailySleepReminder(
        hour: hour,
        minute: minute,
      );
    }

    emit(
      state.copyWith(
        hour: hour,
        minute: minute,
      ),
    );
  }
}
