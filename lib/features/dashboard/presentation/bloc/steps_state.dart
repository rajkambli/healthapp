import 'package:equatable/equatable.dart';

sealed class StepsState extends Equatable {
  const StepsState();

  @override
  List<Object?> get props => [];
}

class StepsInitial extends StepsState {
  const StepsInitial();
}

class StepsPermissionDenied extends StepsState {
  final bool isPermanentlyDenied;

  const StepsPermissionDenied({this.isPermanentlyDenied = false});

  @override
  List<Object?> get props => [isPermanentlyDenied];
}

class StepsLoaded extends StepsState {
  final int todaySteps;
  final int rawReading;

  const StepsLoaded({
    required this.todaySteps,
    this.rawReading = 0,
  });

  @override
  List<Object?> get props => [todaySteps, rawReading];
}

class StepsUnavailable extends StepsState {
  final String message;

  const StepsUnavailable(this.message);

  @override
  List<Object?> get props => [message];
}
