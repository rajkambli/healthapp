import 'package:equatable/equatable.dart';

class ReminderState extends Equatable {
  final bool isEnabled;
  final int hour;
  final int minute;
  final bool isPermissionGranted;
  final String? errorMessage;

  const ReminderState({
    this.isEnabled = false,
    this.hour = 9,
    this.minute = 0,
    this.isPermissionGranted = true,
    this.errorMessage,
  });

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMin = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMin $period';
  }

  ReminderState copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
    bool? isPermissionGranted,
    String? errorMessage,
  }) {
    return ReminderState(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        hour,
        minute,
        isPermissionGranted,
        errorMessage,
      ];
}
