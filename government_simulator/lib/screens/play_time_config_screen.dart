import 'package:flutter/material.dart';
import 'package:government_simulator/utils/constants.dart';

class PlayTimeConfigScreen extends StatefulWidget {
  final Map<String, TimeRange> initialConfig;
  final ValueChanged<Map<String, TimeRange>> onConfigChanged;

  const PlayTimeConfigScreen({
    Key? key,
    required this.initialConfig,
    required this.onConfigChanged,
  }) : super(key: key);

  @override
  State<PlayTimeConfigScreen> createState() => _PlayTimeConfigScreenState();
}

class _PlayTimeConfigScreenState extends State<PlayTimeConfigScreen> {
  late Map<String, TimeRange> _config;
  final _days = [
    ('月', 'monday'),
    ('火', 'tuesday'),
    ('水', 'wednesday'),
    ('木', 'thursday'),
    ('金', 'friday'),
    ('土', 'saturday'),
    ('日', 'sunday'),
  ];

  @override
  void initState() {
    super.initState();
    _config = Map.from(widget.initialConfig);
  }

  void _saveConfig() {
    widget.onConfigChanged(_config);
    Navigator.of(context).pop();
  }

  void _setTimeRange(String day, TimeRange range) {
    setState(() {
      _config[day] = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイ時間設定'),
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⏰ プレイ時間帯を設定',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        'この時間帯でしかゲームをプレイできません。\n設定時間外はゲーム内時間も進みません。',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // 曜日ごと設定
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _days.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppConstants.paddingS),
                itemBuilder: (context, index) {
                  final dayLabel = _days[index].$1;
                  final dayKey = _days[index].$2;
                  final timeRange = _config[dayKey] ?? TimeRange.allDay();

                  return _DayConfigCard(
                    dayLabel: dayLabel,
                    timeRange: timeRange,
                    onChanged: (range) => _setTimeRange(dayKey, range),
                  );
                },
              ),

              const SizedBox(height: AppConstants.paddingL),

              // クイックセット
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚡ クイック設定',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _setAllDayAllowAll,
                              child: const Text('常時プレイ可'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _setWeekdaysOnly,
                              child: const Text('平日のみ'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _setEveningOnly,
                              child: const Text('夜間のみ'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _setWeekendOnly,
                              child: const Text('週末のみ'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // 保存ボタン
              ElevatedButton.icon(
                onPressed: _saveConfig,
                icon: const Icon(Icons.check),
                label: const Text('設定を保存'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL,
                    vertical: AppConstants.paddingM,
                  ),
                  backgroundColor: Color(VisualConstants.colorGood),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setAllDayAllowAll() {
    setState(() {
      for (final day in _days) {
        _config[day.$2] = TimeRange.allDay();
      }
    });
  }

  void _setWeekdaysOnly() {
    setState(() {
      for (int i = 0; i < 5; i++) {
        _config[_days[i].$2] = TimeRange.allDay();
      }
      for (int i = 5; i < 7; i++) {
        _config[_days[i].$2] = TimeRange.blocked();
      }
    });
  }

  void _setEveningOnly() {
    setState(() {
      for (final day in _days) {
        _config[day.$2] = TimeRange(startHour: 18, endHour: 23);
      }
    });
  }

  void _setWeekendOnly() {
    setState(() {
      for (int i = 0; i < 5; i++) {
        _config[_days[i].$2] = TimeRange.blocked();
      }
      for (int i = 5; i < 7; i++) {
        _config[_days[i].$2] = TimeRange.allDay();
      }
    });
  }
}

class _DayConfigCard extends StatefulWidget {
  final String dayLabel;
  final TimeRange timeRange;
  final ValueChanged<TimeRange> onChanged;

  const _DayConfigCard({
    required this.dayLabel,
    required this.timeRange,
    required this.onChanged,
  });

  @override
  State<_DayConfigCard> createState() => _DayConfigCardState();
}

class _DayConfigCardState extends State<_DayConfigCard> {
  late TimeRange _timeRange;

  @override
  void initState() {
    super.initState();
    _timeRange = widget.timeRange;
  }

  void _toggleEnabled() {
    setState(() {
      if (_timeRange.isBlocked) {
        _timeRange = TimeRange.allDay();
      } else {
        _timeRange = TimeRange.blocked();
      }
    });
    widget.onChanged(_timeRange);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _timeRange.startHour, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() {
        _timeRange = TimeRange(
          startHour: picked.hour,
          endHour: _timeRange.endHour,
        );
      });
      widget.onChanged(_timeRange);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _timeRange.endHour, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() {
        _timeRange = TimeRange(
          startHour: _timeRange.startHour,
          endHour: picked.hour,
        );
      });
      widget.onChanged(_timeRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.dayLabel}曜日',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Switch(
                  value: !_timeRange.isBlocked,
                  onChanged: (_) => _toggleEnabled(),
                ),
              ],
            ),
            if (!_timeRange.isBlocked) ...[
              const SizedBox(height: AppConstants.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickStartTime,
                      child: Text(
                        '開始: ${_timeRange.startHour.toString().padLeft(2, '0')}:00',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickEndTime,
                      child: Text(
                        '終了: ${_timeRange.endHour.toString().padLeft(2, '0')}:00',
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.paddingS),
                child: Text(
                  'プレイ不可',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Color(VisualConstants.colorDanger),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// プレイ時間範囲モデル
class TimeRange {
  final int startHour; // 0-23
  final int endHour; // 0-23
  final bool isBlocked;

  TimeRange({
    this.startHour = 0,
    this.endHour = 23,
    this.isBlocked = false,
  });

  factory TimeRange.allDay() => TimeRange();

  factory TimeRange.blocked() => TimeRange(isBlocked: true);

  bool isPlayableAt(DateTime time) {
    if (isBlocked) return false;
    // endHour は「この時までプレイ可」の意図（UI上の終了時刻）だが、
    // showTimePicker は最大23時までしか選べないため、endHour: 23
    // （＝TimeRange.allDay() のデフォルト）で「終日プレイ可」を表現する
    // 前提になっている。ここを time.hour < endHour（排他的）にしていると
    // 23時台が終日プレイ可でも常にプレイ不可になり、「常時プレイ可」
    // ラベルと矛盾していたため、endHour を含む（〜59分まで）比較にする。
    return time.hour >= startHour && time.hour <= endHour;
  }

  @override
  String toString() {
    if (isBlocked) return '利用不可';
    return '$startHour:00 - $endHour:00';
  }
}
