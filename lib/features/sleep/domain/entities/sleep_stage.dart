import 'package:hive_ce/hive.dart';

part 'sleep_stage.g.dart';

@HiveType(typeId: 1)
enum SleepStage {
  @HiveField(0)
  deep,
  @HiveField(1)
  rem,
  @HiveField(2)
  light,
  @HiveField(3)
  awake;

  String get displayName {
    switch (this) {
      case SleepStage.deep:
        return 'Deep Sleep';
      case SleepStage.rem:
        return 'REM Sleep';
      case SleepStage.light:
        return 'Light Sleep';
      case SleepStage.awake:
        return 'Awake';
    }
  }
}
