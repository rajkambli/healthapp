import '../models/calories_data_model.dart';

abstract class CaloriesRemoteDataSource {
  /// Fetches calories burned data for today
  Future<CaloriesDataModel> fetchTodayCalories({int? stepsCount});
}
