import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../reminder/presentation/reminder_toggle.dart';
import '../../../sleep/domain/usecases/calculate_sleep_summary.dart';
import '../../../sleep/presentation/bloc/sleep_bloc.dart';
import '../../../sleep/presentation/bloc/sleep_event.dart';
import '../../../sleep/presentation/bloc/sleep_state.dart';
import '../../../sleep/presentation/pages/sleep_details_page.dart';
import '../../../sleep/presentation/pages/sleep_log_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../bloc/steps_cubit.dart';
import '../bloc/steps_state.dart';
import '../widgets/date_header.dart';
import '../widgets/metric_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CalculateSleepSummary _sleepCalculator = sl<CalculateSleepSummary>();

  @override
  void initState() {
    super.initState();
    // Initialize bloc and cubits
    context.read<DashboardBloc>().add(const DashboardStarted());
    context.read<StepsCubit>().init();
    context.read<SleepBloc>().add(const SleepLogsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Metrics',
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardRefreshed());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SleepLogPage()),
          );
        },
        icon: const Icon(Icons.nightlight_round),
        label: const Text('Log Sleep'),
        backgroundColor: AppColors.sleep,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<DashboardBloc, DashboardState>(
        listenWhen: (previous, current) =>
            previous.isOffline != current.isOffline && current.isOffline,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network unavailable. Displaying cached health metrics.'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          buildWhen: (previous, current) {
            // Avoid rebuilds if only lastUpdated changed without any metric/status change
            return previous.status != current.status ||
                previous.isOffline != current.isOffline ||
                previous.calories != current.calories ||
                previous.errorMessage != current.errorMessage;
          },
          builder: (context, state) {
            // Full screen error only when there's an error and no cached data
            if (state.status == DashboardStatus.failure && state.calories == null) {
              return ErrorView(
                message: state.errorMessage ?? 'Failed to load health metrics.',
                onRetry: () {
                  context.read<DashboardBloc>().add(const DashboardRetried());
                },
              );
            }

            // Initial full screen loading before cache or remote data arrives
            if (state.status == DashboardStatus.loading && state.calories == null) {
              return const LoadingView(message: 'Loading health dashboard...');
            }

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<DashboardBloc>();
                bloc.add(const DashboardRefreshed());
                // Await stream until loading completes
                await bloc.stream.firstWhere(
                  (s) => s.status != DashboardStatus.loading,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 90),
                children: [
                  // Offline Banner (when using cached data after API failure)
                  if (state.isOffline)
                    OfflineBanner(
                      lastUpdated: state.lastUpdated,
                      onRefresh: () {
                        context.read<DashboardBloc>().add(const DashboardRefreshed());
                      },
                    ),

                  // Today's Date Header
                  const DateHeader(),

                  const SizedBox(height: 10),

                  // Section Header: Daily Metrics
                  const SectionHeader(
                    title: "Today's Metrics",
                    subtitle: 'Real-time sensors and estimated burn',
                  ),

                  // 1. Steps Metric Card (Isolated with BlocBuilder to avoid whole dashboard rebuilds)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: _buildStepsCard(context),
                  ),

                  // 2. Calories Metric Card (Isolated with BlocSelector)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: _buildCaloriesCard(context),
                  ),

                  // 3. Sleep Metric Card (Isolated with BlocBuilder for SleepBloc)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: _buildSleepCard(context),
                  ),

                  const SizedBox(height: 16),

                  // Reminder Toggle Section
                  const SectionHeader(
                    title: 'Reminders & Notifications',
                    subtitle: 'Local scheduled alerts for your sleep routine',
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: ReminderToggleCard(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Steps Metric Card: subscribed to StepsCubit so stream updates only rebuild this card
  Widget _buildStepsCard(BuildContext context) {
    return BlocBuilder<StepsCubit, StepsState>(
      builder: (context, state) {
        if (state is StepsPermissionDenied) {
          return MetricCard(
            icon: Icons.directions_walk_rounded,
            iconColor: AppColors.steps,
            title: 'Daily Steps',
            value: 'Permission Required',
            unit: '',
            subtitle: state.isPermanentlyDenied
                ? 'You need to give permission in App Settings to start tracking steps. Tap to open Settings.'
                : 'You need to give permission first to start tracking steps. Tap here to allow.',
            onTap: () {
              if (state.isPermanentlyDenied) {
                context.read<StepsCubit>().openAppSettings();
              } else {
                context.read<StepsCubit>().requestPermission();
              }
            },
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.steps.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isPermanentlyDenied ? Icons.settings_rounded : Icons.lock_open_rounded,
                    size: 14,
                    color: AppColors.steps,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.isPermanentlyDenied ? 'Settings' : 'Grant',
                    style: const TextStyle(
                      color: AppColors.steps,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is StepsUnavailable) {
          return MetricCard(
            icon: Icons.directions_walk_rounded,
            iconColor: AppColors.steps,
            title: 'Daily Steps',
            value: '0',
            unit: 'steps',
            subtitle: 'Hardware sensor inactive on emulator. Steps track automatically on physical device.',
            onTap: () {
              context.read<StepsCubit>().requestPermission();
            },
          );
        }

        final int steps = (state is StepsLoaded) ? state.todaySteps : 0;
        final double progress = steps / AppConstants.defaultDailyStepGoal;

        return MetricCard(
          icon: Icons.directions_walk_rounded,
          iconColor: AppColors.steps,
          title: 'Daily Steps',
          value: steps.toString(),
          unit: 'steps',
          subtitle: 'Goal: ${AppConstants.defaultDailyStepGoal} steps',
          progress: progress,
          isLoading: state is StepsInitial,
        );
      },
    );
  }

  /// Calories Metric Card: Uses BlocSelector to only rebuild when calories data changes
  Widget _buildCaloriesCard(BuildContext context) {
    return BlocSelector<DashboardBloc, DashboardState, (double?, double?, double?, String?, bool)>(
      selector: (state) => (
        state.calories?.totalCalories,
        state.calories?.activeCalories,
        state.calories?.basalCalories,
        state.calories?.source,
        state.status == DashboardStatus.loading && state.calories == null,
      ),
      builder: (context, data) {
        final total = data.$1;
        final active = data.$2;
        final basal = data.$3;
        final source = data.$4;
        final isLoading = data.$5;

        final double displayTotal = total ?? 0.0;
        final double progress = displayTotal / AppConstants.defaultDailyCaloriesGoal;

        final String subtitle = (active != null && basal != null)
            ? 'Active: ${active.toStringAsFixed(0)} kcal • Basal: ${basal.toStringAsFixed(0)} kcal ($source)'
            : 'Estimated daily expenditure';

        return MetricCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.calories,
          title: 'Calories Burned',
          value: displayTotal > 0 ? displayTotal.toStringAsFixed(0) : '0',
          unit: 'kcal',
          subtitle: subtitle,
          progress: progress,
          isLoading: isLoading,
        );
      },
    );
  }

  /// Sleep Metric Card: Shows today's sleep from the manual log; tapping opens Sleep Details screen
  Widget _buildSleepCard(BuildContext context) {
    return BlocBuilder<SleepBloc, SleepState>(
      buildWhen: (prev, curr) {
        // Only rebuild if sessions changed or loading state changed
        return prev != curr;
      },
      builder: (context, state) {
        String sleepValue = 'No sleep logged';
        String sleepUnit = '';
        String? subtitle = 'Tap to view details and stage breakdown';
        double? progress;

        if (state is SleepLoaded && state.sessions.isNotEmpty) {
          final today = DateTime.now();
          // Find today's session or the latest session
          final latestSession = state.sessions.firstWhere(
            (s) => _isSameDay(s.end, today),
            orElse: () => state.sessions.first,
          );

          final summary = _sleepCalculator(latestSession);
          sleepValue = DateFormatters.formatDurationHoursMinutes(summary.total);
          sleepUnit = '';
          progress = summary.total.inMinutes / AppConstants.defaultDailySleepMinutesGoal;

          final deepStr = DateFormatters.formatDurationHoursMinutes(summary.deep);
          final remStr = DateFormatters.formatDurationHoursMinutes(summary.rem);
          subtitle = 'Deep: $deepStr • REM: $remStr (Efficiency: ${summary.efficiencyPercentage.toStringAsFixed(0)}%)';
        }

        return MetricCard(
          icon: Icons.bedtime_rounded,
          iconColor: AppColors.sleep,
          title: 'Sleep',
          value: sleepValue,
          unit: sleepUnit,
          subtitle: subtitle,
          progress: progress,
          isLoading: state is SleepLoading,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SleepDetailsPage()),
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
