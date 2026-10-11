import 'package:equatable/equatable.dart';

class SleepSummary extends Equatable {
  final Duration total;
  final Duration deep;
  final Duration rem;
  final Duration light;
  final Duration awake;
  final Duration timeInBed;

  const SleepSummary({
    required this.total,
    required this.deep,
    required this.rem,
    required this.light,
    required this.awake,
    required this.timeInBed,
  });

  /// Factory creating an empty summary
  factory SleepSummary.empty() => const SleepSummary(
        total: Duration.zero,
        deep: Duration.zero,
        rem: Duration.zero,
        light: Duration.zero,
        awake: Duration.zero,
        timeInBed: Duration.zero,
      );

  double get deepPercentage =>
      total.inSeconds > 0 ? (deep.inSeconds / total.inSeconds) * 100 : 0.0;

  double get remPercentage =>
      total.inSeconds > 0 ? (rem.inSeconds / total.inSeconds) * 100 : 0.0;

  double get lightPercentage =>
      total.inSeconds > 0 ? (light.inSeconds / total.inSeconds) * 100 : 0.0;

  double get awakePercentage =>
      timeInBed.inSeconds > 0 ? (awake.inSeconds / timeInBed.inSeconds) * 100 : 0.0;

  double get efficiencyPercentage =>
      timeInBed.inSeconds > 0 ? (total.inSeconds / timeInBed.inSeconds) * 100 : 0.0;

  @override
  List<Object?> get props => [
        total,
        deep,
        rem,
        light,
        awake,
        timeInBed,
      ];
}
