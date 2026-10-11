import 'dart:math';
import '../models/calories_data_model.dart';
import 'calories_remote_ds.dart';

/// Mock data source providing realistic calorie burn simulation when no API key
/// is supplied or when running in offline/mock test environments.
///
/// Realistic calculation model:
/// - Basal Metabolic Rate (BMR): ~1650 kcal
/// - Active Burn: derived from steps (approx 0.045 kcal per step) or simulated baseline 480-620 kcal
class CaloriesMockDataSource implements CaloriesRemoteDataSource {
  final Random _random;
  final Duration simulatedDelay;

  CaloriesMockDataSource({
    Random? random,
    this.simulatedDelay = const Duration(milliseconds: 400),
  }) : _random = random ?? Random();

  @override
  Future<CaloriesDataModel> fetchTodayCalories({int? stepsCount}) async {
    // Simulate real network latency
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    const double basalCalories = 1680.0;
    double activeCalories;

    if (stepsCount != null && stepsCount > 0) {
      // Step-derived calorie estimate: ~0.045 kcal per step
      activeCalories = (stepsCount * 0.045) + (50 + _random.nextInt(80));
    } else {
      // Default realistic day active expenditure between 520 and 640 kcal
      activeCalories = 540.0 + _random.nextInt(90);
    }

    final double totalCalories = basalCalories + activeCalories;

    return CaloriesDataModel(
      totalCalories: double.parse(totalCalories.toStringAsFixed(1)),
      activeCalories: double.parse(activeCalories.toStringAsFixed(1)),
      basalCalories: basalCalories,
      date: DateTime.now(),
      source: 'Mock / Simulated API',
    );
  }
}
