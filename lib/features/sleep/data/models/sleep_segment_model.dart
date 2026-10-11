import 'package:hive_ce/hive.dart';
import '../../domain/entities/sleep_segment.dart';
import '../../domain/entities/sleep_stage.dart';

part 'sleep_segment_model.g.dart';

@HiveType(typeId: 2)
class SleepSegmentModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final SleepStage stage;

  @HiveField(2)
  final DateTime start;

  @HiveField(3)
  final DateTime end;

  const SleepSegmentModel({
    required this.id,
    required this.stage,
    required this.start,
    required this.end,
  });

  factory SleepSegmentModel.fromEntity(SleepSegment entity) {
    return SleepSegmentModel(
      id: entity.id,
      stage: entity.stage,
      start: entity.start,
      end: entity.end,
    );
  }

  SleepSegment toEntity() {
    return SleepSegment(
      id: id,
      stage: stage,
      start: start,
      end: end,
    );
  }

  factory SleepSegmentModel.fromJson(Map<String, dynamic> json) {
    return SleepSegmentModel(
      id: json['id'] as String,
      stage: SleepStage.values.firstWhere(
        (s) => s.name == json['stage'],
        orElse: () => SleepStage.light,
      ),
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stage': stage.name,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }
}
