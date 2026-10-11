import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sleep_segment.dart';
import '../../domain/entities/sleep_session.dart';
import '../../domain/entities/sleep_stage.dart';
import '../../domain/usecases/validate_sleep_session.dart';
import '../bloc/sleep_bloc.dart';
import '../bloc/sleep_event.dart';

class SleepLogPage extends StatefulWidget {
  const SleepLogPage({super.key});

  @override
  State<SleepLogPage> createState() => _SleepLogPageState();
}

class _SleepLogPageState extends State<SleepLogPage> {
  final _uuid = const Uuid();
  final _validateSleepSession = const ValidateSleepSession();

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  final List<SleepSegment> _segments = [];
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default: Yesterday 11:00 PM to Today 7:00 AM (crossing midnight)
    final yesterday = now.subtract(const Duration(days: 1));
    _startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
    _startTime = const TimeOfDay(hour: 23, minute: 0);

    _endDate = DateTime(now.year, now.month, now.day);
    _endTime = const TimeOfDay(hour: 7, minute: 0);
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime get _startDateTime => _combineDateAndTime(_startDate, _startTime);
  DateTime get _endDateTime => _combineDateAndTime(_endDate, _endTime);

  void _saveLog() {
    setState(() => _validationError = null);

    final session = SleepSession(
      id: _uuid.v4(),
      start: _startDateTime,
      end: _endDateTime,
      segments: List.unmodifiable(_segments),
    );

    final result = _validateSleepSession(session);
    if (!result.isValid) {
      setState(() => _validationError = result.errorMessage);
      return;
    }

    context.read<SleepBloc>().add(SleepLogAdded(session));
    Navigator.of(context).pop();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final initialTime = isStart ? _startTime : _endTime;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = pickedDate;
        _startTime = pickedTime;
      } else {
        _endDate = pickedDate;
        _endTime = pickedTime;
      }
      _validationError = null;
    });
  }

  Future<void> _showAddSegmentDialog() async {
    SleepStage selectedStage = SleepStage.deep;
    DateTime segStart = _startDateTime;
    DateTime segEnd = _startDateTime.add(const Duration(hours: 1, minutes: 30));

    if (segEnd.isAfter(_endDateTime)) {
      segEnd = _endDateTime;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final timeFormat = DateFormat('h:mm a');

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Sleep Stage Segment',
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SleepStage>(
                    initialValue: selectedStage,
                    decoration: const InputDecoration(labelText: 'Stage Type'),
                    items: SleepStage.values.map((stage) {
                      return DropdownMenuItem(
                        value: stage,
                        child: Text(stage.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedStage = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(segStart),
                            );
                            if (time != null) {
                              setSheetState(() {
                                segStart = DateTime(
                                  segStart.year,
                                  segStart.month,
                                  segStart.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          },
                          child: Text('Start: ${timeFormat.format(segStart)}'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(segEnd),
                            );
                            if (time != null) {
                              setSheetState(() {
                                segEnd = DateTime(
                                  segEnd.year,
                                  segEnd.month,
                                  segEnd.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          },
                          child: Text('End: ${timeFormat.format(segEnd)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final newSegment = SleepSegment(
                        id: _uuid.v4(),
                        stage: selectedStage,
                        start: segStart,
                        end: segEnd,
                      );

                      // Pre-validate segment against session
                      final testSession = SleepSession(
                        id: 'test',
                        start: _startDateTime,
                        end: _endDateTime,
                        segments: [..._segments, newSegment],
                      );
                      final valResult = _validateSleepSession(testSession);

                      if (!valResult.isValid) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(
                            content: Text(valResult.errorMessage ?? 'Invalid segment'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _segments.add(newSegment);
                        _segments.sort((a, b) => a.start.compareTo(b.start));
                        _validationError = null;
                      });
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Add Segment'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateTimeFormat = DateFormat('EEE, MMM d • h:mm a');

    final bedDuration = _endDateTime.isAfter(_startDateTime)
        ? _endDateTime.difference(_startDateTime)
        : Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Sleep Session'),
        actions: [
          TextButton(
            onPressed: _saveLog,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_validationError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Text(
              'Bedtime & Wakeup',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.bedtime_outlined, color: AppColors.sleep),
                      title: const Text('Sleep Start (Bedtime)'),
                      subtitle: Text(dateTimeFormat.format(_startDateTime)),
                      trailing: const Icon(Icons.edit_calendar_rounded, size: 20),
                      onTap: () => _pickDateTime(isStart: true),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.wb_sunny_outlined, color: AppColors.calories),
                      title: const Text('Sleep End (Wakeup)'),
                      subtitle: Text(dateTimeFormat.format(_endDateTime)),
                      trailing: const Icon(Icons.edit_calendar_rounded, size: 20),
                      onTap: () => _pickDateTime(isStart: false),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time in Bed:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${bedDuration.inHours}h ${bedDuration.inMinutes % 60}m',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.sleep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sleep Stages (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddSegmentDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Segment'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_segments.isEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'No stage segments added.\nTotal sleep will equal time in bed.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _segments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final seg = _segments[index];
                  final segTime = DateFormat('h:mm a');
                  return Card(
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 8,
                        backgroundColor: _stageColor(seg.stage),
                      ),
                      title: Text(
                        seg.stage.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${segTime.format(seg.start)} - ${segTime.format(seg.end)} (${seg.duration.inMinutes}m)',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () {
                          setState(() {
                            _segments.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveLog,
              child: const Text('Save Sleep Log'),
            ),
          ],
        ),
      ),
    );
  }

  Color _stageColor(SleepStage stage) {
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
}
