import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import 'reminder_cubit.dart';
import 'reminder_state.dart';

class ReminderToggleCard extends StatelessWidget {
  const ReminderToggleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ReminderCubit, ReminderState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Card(
          elevation: 0,
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Sleep Reminder',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: state.isEnabled
                            ? () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: state.hour,
                                    minute: state.minute,
                                  ),
                                );
                                if (time != null && context.mounted) {
                                  context.read<ReminderCubit>().updateTime(
                                        time.hour,
                                        time.minute,
                                      );
                                }
                              }
                            : null,
                        child: Text(
                          state.isEnabled
                              ? 'Scheduled for ${state.formattedTime} (tap to change)'
                              : 'Off • Tap switch to enable',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: state.isEnabled
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            fontWeight: state.isEnabled
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: state.isEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    context.read<ReminderCubit>().toggleReminder(val);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
