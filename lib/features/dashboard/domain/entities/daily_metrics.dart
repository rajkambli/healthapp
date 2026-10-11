import 'package:equatable/equatable.dart';
import 'calories_data.dart';

class DailyMetrics extends Equatable {
  final DateTime date;
  final CaloriesData calories;
  final DateTime lastUpdated;
  final bool isFromCache;

  const DailyMetrics({
    required this.date,
    required this.calories,
    required this.lastUpdated,
    this.isFromCache = false,
  });

  DailyMetrics copyWith({
    DateTime? date,
    CaloriesData? calories,
    DateTime? lastUpdated,
    bool? isFromCache,
  }) {
    return DailyMetrics(
      date: date ?? this.date,
      calories: calories ?? this.calories,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
        date,
        calories,
        lastUpdated,
        isFromCache,
      ];
}
