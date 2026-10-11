import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/constants.dart';
import '../models/calories_data_model.dart';
import 'calories_remote_ds.dart';

class CaloriesRemoteDataSourceImpl implements CaloriesRemoteDataSource {
  final DioClient _dioClient;
  final String _apiKey;

  CaloriesRemoteDataSourceImpl({
    required DioClient dioClient,
    String? apiKey,
  })  : _dioClient = dioClient,
        _apiKey = apiKey ?? AppConstants.caloriesApiKey;

  @override
  Future<CaloriesDataModel> fetchTodayCalories({int? stepsCount}) async {
    try {
      if (_apiKey.isEmpty) {
        throw const ServerException('No API key configured for Calories API.');
      }

      // Query calories burned from walking/running based on user activity
      final response = await _dioClient.dio.get(
        AppConstants.apiNinjasCaloriesUrl,
        queryParameters: {'activity': 'brisk walking'},
        options: Options(
          headers: {'X-Api-Key': _apiKey},
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return CaloriesDataModel.fromApiNinjas(
          response.data as List<dynamic>,
          date: DateTime.now(),
        );
      } else {
        throw ServerException(
          'Unexpected API response: ${response.statusCode}',
          response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(e.message ?? 'Failed to communicate with Calories API');
    } catch (e) {
      throw ServerException('Failed to fetch calories data: $e');
    }
  }
}
