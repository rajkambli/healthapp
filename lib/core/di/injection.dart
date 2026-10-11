import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../storage/hive_service.dart';
import '../utils/constants.dart';

// Dashboard
import '../../features/dashboard/data/datasources/calories_mock_ds.dart';
import '../../features/dashboard/data/datasources/calories_remote_ds.dart';
import '../../features/dashboard/data/datasources/calories_remote_ds_impl.dart';
import '../../features/dashboard/data/datasources/metrics_local_ds.dart';
import '../../features/dashboard/data/datasources/steps_ds.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/bloc/steps_cubit.dart';

// Sleep
import '../../features/sleep/data/datasources/sleep_local_ds.dart';
import '../../features/sleep/data/repositories/sleep_repository_impl.dart';
import '../../features/sleep/domain/repositories/sleep_repository.dart';
import '../../features/sleep/domain/usecases/calculate_sleep_summary.dart';
import '../../features/sleep/domain/usecases/validate_sleep_session.dart';
import '../../features/sleep/presentation/bloc/sleep_bloc.dart';

// Reminder
import '../../features/reminder/data/notification_service.dart';
import '../../features/reminder/data/reminder_local_ds.dart';
import '../../features/reminder/presentation/reminder_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // -------------------------------------------------------------
  // 1. Core Services & Storage
  // -------------------------------------------------------------
  final hiveService = HiveService();
  await hiveService.init();
  sl.registerSingleton<HiveService>(hiveService);

  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  final notificationService = NotificationServiceImpl();
  sl.registerSingleton<NotificationService>(notificationService);

  // -------------------------------------------------------------
  // 2. Data Sources
  // -------------------------------------------------------------
  // Switch between live API and mock data source based on CALORIES_API_KEY dart-define
  if (AppConstants.caloriesApiKey.isNotEmpty) {
    debugPrint('DI: Initializing Live CaloriesRemoteDataSourceImpl (Key provided)');
    sl.registerLazySingleton<CaloriesRemoteDataSource>(
      () => CaloriesRemoteDataSourceImpl(
        dioClient: sl(),
        apiKey: AppConstants.caloriesApiKey,
      ),
    );
  } else {
    debugPrint('DI: Initializing CaloriesMockDataSource (No key provided / Reviewer mode)');
    sl.registerLazySingleton<CaloriesRemoteDataSource>(
      () => CaloriesMockDataSource(),
    );
  }

  sl.registerLazySingleton<MetricsLocalDataSource>(
    () => MetricsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<StepsDataSource>(
    () => StepsDataSourceImpl(),
  );
  sl.registerLazySingleton<SleepLocalDataSource>(
    () => SleepLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ReminderLocalDataSource>(
    () => ReminderLocalDataSourceImpl(sl()),
  );

  // -------------------------------------------------------------
  // 3. Repositories
  // -------------------------------------------------------------
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<SleepRepository>(
    () => SleepRepositoryImpl(localDataSource: sl()),
  );

  // -------------------------------------------------------------
  // 4. Domain Use Cases
  // -------------------------------------------------------------
  sl.registerLazySingleton<CalculateSleepSummary>(
    () => const CalculateSleepSummary(),
  );
  sl.registerLazySingleton<ValidateSleepSession>(
    () => const ValidateSleepSession(),
  );

  // -------------------------------------------------------------
  // 5. Blocs & Cubits (Factory instances for presentation)
  // -------------------------------------------------------------
  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(repository: sl()),
  );
  sl.registerFactory<StepsCubit>(
    () => StepsCubit(
      stepsDataSource: sl(),
      repository: sl(),
    ),
  );
  sl.registerFactory<SleepBloc>(
    () => SleepBloc(
      sleepRepository: sl(),
      validateSleepSession: sl(),
    ),
  );
  sl.registerFactory<ReminderCubit>(
    () => ReminderCubit(
      notificationService: sl(),
      localDataSource: sl(),
    ),
  );
}
