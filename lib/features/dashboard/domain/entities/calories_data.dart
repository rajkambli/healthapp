import 'package:equatable/equatable.dart';

class CaloriesData extends Equatable {
  final double totalCalories;
  final double activeCalories;
  final double basalCalories;
  final DateTime date;
  final String source; // e.g. "API Ninjas", "Mock / Estimated"

  const CaloriesData({
    required this.totalCalories,
    required this.activeCalories,
    required this.basalCalories,
    required this.date,
    this.source = 'API Ninjas',
  });

  @override
  List<Object?> get props => [
        totalCalories,
        activeCalories,
        basalCalories,
        date,
        source,
      ];
}
