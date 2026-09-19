/// パックイベント管理サービス
/// イベントのトリガー、選択肢処理、進捗追跡
library;

import 'package:government_simulator/models/story_pack_event.dart';
import 'package:government_simulator/data/pack_events_data.dart';

/// パックイベント管理サービス
class PackEventService {
  /// 全パックイベント
  static final List<StoryPackEvent> allEvents = allPackEvents;

  /// イベントIDからイベントを取得
  static StoryPackEvent? getEventById(String eventId) {
    try {
      return allEvents.firstWhere((e) => e.id == eventId);
    } catch (e) {
      return null;
    }
  }

  /// パック内のイベント一覧を取得
  static List<StoryPackEvent> getEventsInPack(String packId) {
    return allEvents.where((e) => e.packId == packId).toList();
  }

  /// シナリオで発生可能なイベント一覧を取得
  static List<StoryPackEvent> getEventsForScenario(String scenarioId) {
    return allEvents
        .where((e) => e.triggerScenarioIds.contains(scenarioId))
        .toList();
  }

  /// 特定の年に発生しうるイベント一覧を取得（発生年に幅がある場合はその範囲を含む）
  static List<StoryPackEvent> getEventsForYear(int year) {
    return allEvents.where((e) => _matchesYear(e, year)).toList();
  }

  /// 指定パック内で特定の年に発生しうるイベント一覧を取得
  static List<StoryPackEvent> getEventsForPackAndYear(String packId, int year) {
    return allEvents
        .where((e) => e.packId == packId && _matchesYear(e, year))
        .toList();
  }

  static bool _matchesYear(StoryPackEvent event, int year) {
    if (event.triggerYear == null) return false;
    if (event.triggerYearMax == null) return event.triggerYear == year;
    return year >= event.triggerYear! && year <= event.triggerYearMax!;
  }

  /// パックで優先度の高いイベントを取得
  static List<StoryPackEvent> getHighPriorityEventsInPack(
    String packId, {
    int minPriority = 4,
  }) {
    return allEvents
        .where((e) => e.packId == packId && e.priority >= minPriority)
        .toList();
  }

  /// タグでイベントを検索
  static List<StoryPackEvent> getEventsByTag(String tag) {
    return allEvents.where((e) => e.tags.contains(tag)).toList();
  }

  /// イベントテーマで検索
  static List<StoryPackEvent> getEventsByTheme(String theme) {
    return allEvents.where((e) => e.theme == theme).toList();
  }

  /// イベントタイプで検索
  static List<StoryPackEvent> getEventsByType(String eventType) {
    return allEvents.where((e) => e.eventType == eventType).toList();
  }

  /// 後続イベントを取得
  static StoryPackEvent? getFollowUpEvent(String eventId) {
    final event = getEventById(eventId);
    if (event?.followUpEventId == null) return null;
    return getEventById(event!.followUpEventId!);
  }

  /// 選択肢を取得
  static StoryPackEventChoice? getChoice(String eventId, String choiceId) {
    final event = getEventById(eventId);
    if (event == null) return null;
    try {
      return event.choices.firstWhere((c) => c.id == choiceId);
    } catch (e) {
      return null;
    }
  }

  /// 選択肢から後続イベントを取得
  static StoryPackEvent? getFollowUpEventFromChoice(
    String eventId,
    String choiceId,
  ) {
    final choice = getChoice(eventId, choiceId);
    if (choice?.followUpEventId == null) return null;
    return getEventById(choice!.followUpEventId!);
  }

  /// イベントの影響結果を計算
  static Map<String, dynamic> calculateEventImpact(
    String eventId,
    String choiceId,
  ) {
    final choice = getChoice(eventId, choiceId);
    if (choice == null) return {};
    return choice.outcomes;
  }

  /// パック内の全イベント数を取得
  static int getEventCountInPack(String packId) {
    return getEventsInPack(packId).length;
  }

  /// パック内のユニークイベント数を取得
  static int getUniqueEventCountInPack(String packId) {
    return getEventsInPack(packId).where((e) => e.isUnique).length;
  }

  /// パック内のイベント統計情報を取得
  static Map<String, dynamic> getPackEventStats(String packId) {
    final events = getEventsInPack(packId);
    final byType = <String, int>{};
    final byTheme = <String, int>{};

    for (final event in events) {
      byType[event.eventType] = (byType[event.eventType] ?? 0) + 1;
      byTheme[event.theme] = (byTheme[event.theme] ?? 0) + 1;
    }

    return {
      'totalEvents': events.length,
      'uniqueEvents': events.where((e) => e.isUnique).length,
      'byType': byType,
      'byTheme': byTheme,
      'averagePriority':
          events.isEmpty ? 0 : events.map((e) => e.priority).reduce((a, b) => a + b) / events.length,
    };
  }

  /// シナリオ別イベント統計を取得
  static Map<String, int> getEventCountByScenario(String packId) {
    final events = getEventsInPack(packId);
    final counts = <String, int>{};

    for (final event in events) {
      for (final scenarioId in event.triggerScenarioIds) {
        counts[scenarioId] = (counts[scenarioId] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// イベントチェーンを取得（後続イベント込み）
  static List<StoryPackEvent> getEventChain(String startEventId) {
    final chain = <StoryPackEvent>[];
    var currentEvent = getEventById(startEventId);

    while (currentEvent != null) {
      chain.add(currentEvent);
      currentEvent = getFollowUpEvent(currentEvent.id);
    }

    return chain;
  }

  /// 全ユニークテーマを取得
  static List<String> getAllEventThemes() {
    final themes = <String>{};
    for (final event in allEvents) {
      themes.add(event.theme);
    }
    return themes.toList();
  }

  /// 全ユニークタイプを取得
  static List<String> getAllEventTypes() {
    final types = <String>{};
    for (final event in allEvents) {
      types.add(event.eventType);
    }
    return types.toList();
  }

  /// 全ユニークタグを取得
  static List<String> getAllEventTags() {
    final tags = <String>{};
    for (final event in allEvents) {
      tags.addAll(event.tags);
    }
    return tags.toList();
  }
}
