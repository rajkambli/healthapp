import 'package:equatable/equatable.dart';

class StepsData extends Equatable {
  final int todaySteps;
  final int rawPedometerSteps;
  final int baselineSteps;
  final DateTime date;

  const StepsData({
    required this.todaySteps,
    required this.rawPedometerSteps,
    required this.baselineSteps,
    required this.date,
  });

  @override
  List<Object?> get props => [
        todaySteps,
        rawPedometerSteps,
        baselineSteps,
        date,
      ];
}
