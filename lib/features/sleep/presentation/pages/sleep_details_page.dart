import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/sleep_session.dart';
import '../../domain/entities/sleep_stage.dart';
import '../../domain/entities/sleep_summary.dart';
import '../../domain/usecases/calculate_sleep_summary.dart';
import '../bloc/sleep_bloc.dart';
import '../bloc/sleep_event.dart';
import '../bloc/sleep_state.dart';
import '../widgets/sleep_breakdown_bar.dart';
import 'sleep_log_page.dart';

class SleepDetailsPage extends StatefulWidget {
  final String? initialSessionId;

  const SleepDetailsPage({super.key, this.initialSessionId});

  @override
  State<SleepDetailsPage> createState() => _SleepDetailsPageState();
}

class _SleepDetailsPageState extends State<SleepDetailsPage> {
  final CalculateSleepSummary _calculator = sl<CalculateSleepSummary>();
  String? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _selectedSessionId = widget.initialSessionId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Sleep Log',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SleepLogPage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SleepBloc, SleepState>(
        builder: (context, state) {
          if (state is SleepLoading) {
            return const LoadingView(message: 'Calculating sleep breakdown...');
          }

          if (state is SleepFailure && state.cachedSessions.isEmpty) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<SleepBloc>().add(const SleepLogsRequested());
              },
            );
          }

          final sessions = state is SleepLoaded
              ? state.sessions
              : (state is SleepFailure ? state.cachedSessions : <SleepSession>[]);

          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.sleep.withValues(alpha: isDark ? 0.2 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.nights_stay_rounded,
                        size: 48,
                        color: AppColors.sleep,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No Sleep Logged Yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Log your nightly sleep to view detailed stage breakdowns, efficiency, and sleep patterns.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SleepLogPage()),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Log Sleep'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Pick the active session
          final currentSession = sessions.firstWhere(
            (s) => s.id == _selectedSessionId,
            orElse: () => sessions.first,
          );

          // Use the pure domain usecase to compute summary
          final SleepSummary summary = _calculator(currentSession);
          final timeFormat = DateFormat('h:mm a');
          final dateFormat = DateFormat('EEEE, MMM d');

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session selector if more than 1 session
                if (sessions.length > 1) ...[
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sessions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final sess = sessions[index];
                        final isSelected = sess.id == currentSession.id;
                        return ChoiceChip(
                          label: Text(DateFormat('MMM d').format(sess.start)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSessionId = sess.id);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Session Date and Delete Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(currentSession.start),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${timeFormat.format(currentSession.start)} - ${timeFormat.format(currentSession.end)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      tooltip: 'Delete log',
                      onPressed: () => _confirmDelete(context, currentSession.id),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Total Sleep Headline Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Sleep',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormatters.formatDurationHoursMinutes(summary.total),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.sleep,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Efficiency ${summary.efficiencyPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time in Bed',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              DateFormatters.formatDurationHoursMinutes(summary.timeInBed),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Awake Time',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              DateFormatters.formatDurationHoursMinutes(summary.awake),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.awake,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sleep Stages Breakdown Card
                Text(
                  'Sleep Stages Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SleepBreakdownBar(summary: summary),
                        const SizedBox(height: 18),
                        SleepStageLegend(
                          stage: SleepStage.deep,
                          duration: summary.deep,
                          percentage: summary.deepPercentage,
                        ),
                        const Divider(height: 12),
                        SleepStageLegend(
                          stage: SleepStage.rem,
                          duration: summary.rem,
                          percentage: summary.remPercentage,
                        ),
                        const Divider(height: 12),
                        SleepStageLegend(
                          stage: SleepStage.light,
                          duration: summary.light,
                          percentage: summary.lightPercentage,
                        ),
                        const Divider(height: 12),
                        SleepStageLegend(
                          stage: SleepStage.awake,
                          duration: summary.awake,
                          percentage: summary.awakePercentage,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Recorded Stage Segments List
                if (currentSession.segments.isNotEmpty) ...[
                  Text(
                    'Recorded Segments (${currentSession.segments.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentSession.segments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final segment = currentSession.segments[index];
                      return Card(
                        child: ListTile(
                          dense: true,
                          title: Text(
                            segment.stage.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${timeFormat.format(segment.start)} - ${timeFormat.format(segment.end)}',
                          ),
                          trailing: Text(
                            DateFormatters.formatDurationHoursMinutes(segment.duration),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Sleep Log?'),
        content: const Text('Are you sure you want to permanently delete this sleep session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SleepBloc>().add(SleepLogDeleted(sessionId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep log deleted')),
      );
    }
  }
}
