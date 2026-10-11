import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthapp/features/reminder/data/notification_service.dart';
import 'package:healthapp/features/reminder/data/reminder_local_ds.dart';
import 'package:healthapp/features/reminder/presentation/reminder_cubit.dart';
import 'package:healthapp/features/reminder/presentation/reminder_state.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}
class MockReminderLocalDataSource extends Mock implements ReminderLocalDataSource {}

void main() {
  late MockNotificationService mockNotificationService;
  late MockReminderLocalDataSource mockLocalDataSource;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockLocalDataSource = MockReminderLocalDataSource();
  });

  group('ReminderCubit', () {
    blocTest<ReminderCubit, ReminderState>(
      'init loads saved reminder settings and schedules if enabled',
      build: () {
        when(() => mockLocalDataSource.isReminderEnabled())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getReminderTime())
            .thenAnswer((_) async => (hour: 8, minute: 30));
        when(() => mockNotificationService.scheduleDailySleepReminder(
              hour: 8,
              minute: 30,
            )).thenAnswer((_) async {});
        return ReminderCubit(
          notificationService: mockNotificationService,
          localDataSource: mockLocalDataSource,
        );
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        const ReminderState(
          isEnabled: true,
          hour: 8,
          minute: 30,
          isPermissionGranted: true,
        ),
      ],
      verify: (_) {
        verify(() => mockNotificationService.scheduleDailySleepReminder(
              hour: 8,
              minute: 30,
            )).called(1);
      },
    );

    blocTest<ReminderCubit, ReminderState>(
      'toggleReminder(true) requests permission, persists, and schedules notification',
      build: () {
        when(() => mockNotificationService.requestPermissions())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.setReminderEnabled(true))
            .thenAnswer((_) async {});
        when(() => mockNotificationService.scheduleDailySleepReminder(
              hour: 9,
              minute: 0,
            )).thenAnswer((_) async {});
        return ReminderCubit(
          notificationService: mockNotificationService,
          localDataSource: mockLocalDataSource,
        );
      },
      act: (cubit) => cubit.toggleReminder(true),
      expect: () => [
        const ReminderState(
          isEnabled: true,
          hour: 9,
          minute: 0,
          isPermissionGranted: true,
          errorMessage: null,
        ),
      ],
    );

    blocTest<ReminderCubit, ReminderState>(
      'toggleReminder(true) when permission denied emits failure and stays disabled',
      build: () {
        when(() => mockNotificationService.requestPermissions())
            .thenAnswer((_) async => false);
        return ReminderCubit(
          notificationService: mockNotificationService,
          localDataSource: mockLocalDataSource,
        );
      },
      act: (cubit) => cubit.toggleReminder(true),
      expect: () => [
        const ReminderState(
          isEnabled: false,
          isPermissionGranted: false,
          errorMessage: 'Notification permission was denied in device settings.',
        ),
      ],
    );

    blocTest<ReminderCubit, ReminderState>(
      'toggleReminder(false) cancels notification and saves disabled state',
      build: () {
        when(() => mockLocalDataSource.setReminderEnabled(false))
            .thenAnswer((_) async {});
        when(() => mockNotificationService.cancelSleepReminder())
            .thenAnswer((_) async {});
        return ReminderCubit(
          notificationService: mockNotificationService,
          localDataSource: mockLocalDataSource,
        );
      },
      seed: () => const ReminderState(isEnabled: true, hour: 9, minute: 0),
      act: (cubit) => cubit.toggleReminder(false),
      expect: () => [
        const ReminderState(
          isEnabled: false,
          hour: 9,
          minute: 0,
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verify(() => mockNotificationService.cancelSleepReminder()).called(1);
      },
    );

    blocTest<ReminderCubit, ReminderState>(
      'updateTime persists new time and reschedules if enabled',
      build: () {
        when(() => mockLocalDataSource.setReminderTime(10, 15))
            .thenAnswer((_) async {});
        when(() => mockNotificationService.scheduleDailySleepReminder(
              hour: 10,
              minute: 15,
            )).thenAnswer((_) async {});
        return ReminderCubit(
          notificationService: mockNotificationService,
          localDataSource: mockLocalDataSource,
        );
      },
      seed: () => const ReminderState(isEnabled: true, hour: 9, minute: 0),
      act: (cubit) => cubit.updateTime(10, 15),
      expect: () => [
        const ReminderState(
          isEnabled: true,
          hour: 10,
          minute: 15,
        ),
      ],
      verify: (_) {
        verify(() => mockLocalDataSource.setReminderTime(10, 15)).called(1);
        verify(() => mockNotificationService.scheduleDailySleepReminder(
              hour: 10,
              minute: 15,
            )).called(1);
      },
    );
  });
}
