import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sleep_stage.dart';
import '../../domain/entities/sleep_summary.dart';

class SleepBreakdownBar extends StatelessWidget {
  final SleepSummary summary;

  const SleepBreakdownBar({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.timeInBed.inSeconds == 0) {
      return const SizedBox.shrink();
    }

    final deepFlex = summary.deep.inSeconds;
    final remFlex = summary.rem.inSeconds;
    final lightFlex = summary.light.inSeconds;
    final awakeFlex = summary.awake.inSeconds;
    final unclassifiedFlex = summary.timeInBed.inSeconds - (deepFlex + remFlex + lightFlex + awakeFlex);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 18,
        child: Row(
          children: [
            if (deepFlex > 0)
              Expanded(
                flex: deepFlex,
                child: Container(
                  color: AppColors.deepSleep,
                  child: const Tooltip(message: 'Deep Sleep', child: SizedBox.expand()),
                ),
              ),
            if (remFlex > 0)
              Expanded(
                flex: remFlex,
                child: Container(
                  color: AppColors.remSleep,
                  child: const Tooltip(message: 'REM Sleep', child: SizedBox.expand()),
                ),
              ),
            if (lightFlex > 0)
              Expanded(
                flex: lightFlex,
                child: Container(
                  color: AppColors.lightSleep,
                  child: const Tooltip(message: 'Light Sleep', child: SizedBox.expand()),
                ),
              ),
            if (awakeFlex > 0)
              Expanded(
                flex: awakeFlex,
                child: Container(
                  color: AppColors.awake,
                  child: const Tooltip(message: 'Awake', child: SizedBox.expand()),
                ),
              ),
            if (unclassifiedFlex > 0)
              Expanded(
                flex: unclassifiedFlex,
                child: Container(
                  color: Colors.grey.shade400,
                  child: const Tooltip(message: 'General Sleep', child: SizedBox.expand()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SleepStageLegend extends StatelessWidget {
  final SleepStage stage;
  final Duration duration;
  final double percentage;

  const SleepStageLegend({
    super.key,
    required this.stage,
    required this.duration,
    required this.percentage,
  });

  Color _colorForStage(SleepStage stage) {
    switch (stage) {
      case SleepStage.deep:
        return AppColors.deepSleep;
      case SleepStage.rem:
        return AppColors.remSleep;
      case SleepStage.light:
        return AppColors.lightSleep;
      case SleepStage.awake:
        return AppColors.awake;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _colorForStage(stage),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              stage.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${duration.inHours}h ${duration.inMinutes % 60}m (${percentage.toStringAsFixed(0)}%)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
