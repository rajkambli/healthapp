import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/steps_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/reminder/presentation/reminder_cubit.dart';
import 'features/sleep/presentation/bloc/sleep_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (_) => sl<DashboardBloc>(),
        ),
        BlocProvider<StepsCubit>(
          create: (_) => sl<StepsCubit>(),
        ),
        BlocProvider<SleepBloc>(
          create: (_) => sl<SleepBloc>(),
        ),
        BlocProvider<ReminderCubit>(
          create: (_) => sl<ReminderCubit>()..init(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const DashboardPage(),
      ),
    );
  }
}
