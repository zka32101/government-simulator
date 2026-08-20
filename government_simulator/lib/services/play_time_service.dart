import 'package:shared_preferences/shared_preferences.dart';
import 'package:government_simulator/screens/play_time_config_screen.dart';
import 'dart:convert';

class PlayTimeService {
  static const String _configKey = 'play_time_config';
  static const String _lastGameTickKey = 'last_game_tick';

  // デフォルト設定：全時間帯プレイ可
  static Map<String, TimeRange> getDefaultConfig() {
    return {
      'monday': TimeRange.allDay(),
      'tuesday': TimeRange.allDay(),
      'wednesday': TimeRange.allDay(),
      'thursday': TimeRange.allDay(),
      'friday': TimeRange.allDay(),
      'saturday': TimeRange.allDay(),
      'sunday': TimeRange.allDay(),
    };
  }

  // 現在の曜日キーを取得
  static String getDayKey(DateTime date) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[date.weekday - 1];
  }

  // 現在がプレイ可能な時間帯か判定
  static Future<bool> isPlayableNow(
      Map<String, TimeRange> config) async {
    final now = DateTime.now();
    final dayKey = getDayKey(now);
    final todayConfig = config[dayKey] ?? TimeRange.allDay();
    return todayConfig.isPlayableAt(now);
  }

  // ゲーム内日数の経過を計算
  static Future<int> calculateDaysPassed(
    Map<String, TimeRange> config,
    DateTime lastPlayedAt,
  ) async {
    // プレイ可能な時間を集計
    final now = DateTime.now();
    int dayCount = 0;

    DateTime current = lastPlayedAt;
    while (current.isBefore(now)) {
      final dayKey = getDayKey(current);
      final dayConfig = config[dayKey] ?? TimeRange.allDay();

      // その日がプレイ可能な時間帯を過ぎたか判定
      if (!dayConfig.isBlocked) {
        // プレイ可能時間帯の終了時刻を過ぎたか確認
        final endOfDay = DateTime(
          current.year,
          current.month,
          current.day,
          dayConfig.endHour,
          0,
          0,
        );

        if (now.isAfter(endOfDay)) {
          dayCount++;
        }
      }

      // 次の日へ
      current = DateTime(
        current.year,
        current.month,
        current.day + 1,
      );
    }

    return dayCount;
  }

  // 次のプレイ可能時刻を計算
  static DateTime getNextPlayableTime(
    Map<String, TimeRange> config,
  ) {
    DateTime current = DateTime.now();

    // 全曜日が isBlocked な設定（UIの禁止トグルで作れてしまう）だと
    // 永久にプレイ可能な日が見つからず while(true) が無限ループして
    // 呼び出し元のアイソレートがフリーズするバグがあった。曜日の
    // 巡回は最大7通りしかないため、1週間分（+念のため1日）試しても
    // 見つからなければ「常にプレイ不可」の設定として明示的に例外にする。
    for (var i = 0; i < 8; i++) {
      final dayKey = getDayKey(current);
      final dayConfig = config[dayKey] ?? TimeRange.allDay();

      if (!dayConfig.isBlocked) {
        // その日のプレイ可能開始時刻
        final startTime = DateTime(
          current.year,
          current.month,
          current.day,
          dayConfig.startHour,
          0,
          0,
        );

        if (current.isBefore(startTime)) {
          return startTime;
        }

        // 開始時刻は過ぎているが、終了時刻は未到達か確認
        final endTime = DateTime(
          current.year,
          current.month,
          current.day,
          dayConfig.endHour,
          0,
          0,
        );

        if (current.isBefore(endTime)) {
          // 今、プレイ可能
          return current;
        }
      }

      // 次の日へ
      current = DateTime(
        current.year,
        current.month,
        current.day + 1,
      );
    }

    throw StateError(
      'すべての曜日がプレイ不可に設定されているため、次のプレイ可能時刻が'
      '存在しません。少なくとも1曜日はプレイ可能にしてください。',
    );
  }

  // 設定をローカルストレージに保存
  static Future<void> saveConfig(
    Map<String, TimeRange> config,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = jsonEncode(
      config.map(
        (key, range) => MapEntry(
          key,
          {
            'startHour': range.startHour,
            'endHour': range.endHour,
            'isBlocked': range.isBlocked,
          },
        ),
      ),
    );
    await prefs.setString(_configKey, configJson);
  }

  // ローカルストレージから設定を読み込み
  static Future<Map<String, TimeRange>> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);

    if (configJson == null) {
      return getDefaultConfig();
    }

    try {
      final decoded = jsonDecode(configJson) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          TimeRange(
            startHour: value['startHour'] ?? 0,
            endHour: value['endHour'] ?? 23,
            isBlocked: value['isBlocked'] ?? false,
          ),
        ),
      );
    } catch (e) {
      return getDefaultConfig();
    }
  }

  // 最終ゲーム更新時刻を保存
  static Future<void> saveLastGameTick(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastGameTickKey, time.toIso8601String());
  }

  // 最終ゲーム更新時刻を取得
  static Future<DateTime> getLastGameTick() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_lastGameTickKey);

    if (timeStr == null) {
      return DateTime.now();
    }

    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  // ゲーム進行を制御（時間設定に基づいて）
  static Future<GameProgressUpdate> updateGameProgress(
    Map<String, TimeRange> config,
    DateTime lastPlayedAt,
    int currentDay,
    int currentYear,
  ) async {
    final isPlayable = await isPlayableNow(config);
    final daysPassed = await calculateDaysPassed(config, lastPlayedAt);

    if (!isPlayable) {
      // プレイ不可時間帯
      return GameProgressUpdate(
        shouldAdvanceTime: false,
        daysPassed: 0,
        nextPlayableTime: getNextPlayableTime(config),
        canPlay: false,
      );
    }

    if (daysPassed == 0) {
      // 1日経過していない
      return GameProgressUpdate(
        shouldAdvanceTime: false,
        daysPassed: 0,
        nextPlayableTime: null,
        canPlay: true,
      );
    }

    // ゲーム内日数を更新
    int newDay = currentDay + daysPassed;
    int newYear = currentYear;

    while (newDay > 7) {
      newDay -= 7;
      newYear += 1;
    }

    return GameProgressUpdate(
      shouldAdvanceTime: true,
      daysPassed: daysPassed,
      nextPlayableTime: null,
      canPlay: true,
      newDay: newDay,
      newYear: newYear,
    );
  }
}

// ゲーム進行更新情報
class GameProgressUpdate {
  final bool shouldAdvanceTime;
  final int daysPassed;
  final DateTime? nextPlayableTime;
  final bool canPlay;
  final int? newDay;
  final int? newYear;

  GameProgressUpdate({
    required this.shouldAdvanceTime,
    required this.daysPassed,
    required this.nextPlayableTime,
    required this.canPlay,
    this.newDay,
    this.newYear,
  });
}
