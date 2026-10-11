import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatters.dart';

class OfflineBanner extends StatelessWidget {
  final DateTime? lastUpdated;
  final VoidCallback? onRefresh;

  const OfflineBanner({
    super.key,
    this.lastUpdated,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final updatedText = lastUpdated != null
        ? 'Last updated: ${DateFormatters.formatLastUpdated(lastUpdated!)}'
        : 'Displaying cached data';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.warningContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Offline Mode',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                  ),
                ),
                Text(
                  updatedText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.amber.shade100 : Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          if (onRefresh != null) ...[
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
              tooltip: 'Retry sync',
              onPressed: onRefresh,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}
