import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String value;
  final String unit;
  final String? subtitle;
  final double? progress;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? trailing;

  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    required this.value,
    required this.unit,
    this.subtitle,
    this.progress,
    this.onTap,
    this.isLoading = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final iconBg = iconBackgroundColor ?? iconColor.withValues(alpha: isDark ? 0.2 : 0.12);

    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Title + Trailing
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  if (trailing case final Widget t) t,
                  if (onTap != null && trailing == null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      size: 22,
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Value & Unit or Loading State
              if (isLoading) ...[
                const SizedBox(
                  height: 36,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Optional Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],

              // Optional Progress Indicator
              if (progress != null && !isLoading) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress!.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
