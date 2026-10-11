import 'package:hive_ce/hive.dart';
import '../../domain/entities/sleep_session.dart';
import 'sleep_segment_model.dart';

part 'sleep_session_model.g.dart';

@HiveType(typeId: 3)
class SleepSessionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime start;

  @HiveField(2)
  final DateTime end;

  @HiveField(3)
  final List<SleepSegmentModel> segments;

  const SleepSessionModel({
    required this.id,
    required this.start,
    required this.end,
    this.segments = const [],
  });

  factory SleepSessionModel.fromEntity(SleepSession entity) {
    return SleepSessionModel(
      id: entity.id,
      start: entity.start,
      end: entity.end,
      segments: entity.segments
          .map((s) => SleepSegmentModel.fromEntity(s))
          .toList(),
    );
  }

  SleepSession toEntity() {
    return SleepSession(
      id: id,
      start: start,
      end: end,
      segments: segments.map((s) => s.toEntity()).toList(),
    );
  }

  factory SleepSessionModel.fromJson(Map<String, dynamic> json) {
    return SleepSessionModel(
      id: json['id'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      segments: (json['segments'] as List<dynamic>?)
              ?.map((s) => SleepSegmentModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }
}
