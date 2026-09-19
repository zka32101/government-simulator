/// パックイベント処理エンジン
/// イベントのトリガー、進捗管理、結果適用
library;

import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/story_pack_event.dart';
import 'package:government_simulator/services/pack_event_service.dart';

/// パックイベント処理エンジン
class PackEventEngine {
  /// 指定シナリオで発生可能なイベントを確認
  static List<StoryPackEvent> checkEventsForScenario(
    String scenarioId,
    String? currentPackId,
  ) {
    var events = PackEventService.getEventsForScenario(scenarioId);

    if (currentPackId != null) {
      events = events.where((e) => e.packId == currentPackId).toList();
    }

    return events;
  }

  /// 指定年のイベントを確認
  static List<StoryPackEvent> checkEventsForYear(
    int year,
    String? currentPackId,
  ) {
    var events = PackEventService.getEventsForYear(year);

    if (currentPackId != null) {
      events = events.where((e) => e.packId == currentPackId).toList();
    }

    return events;
  }

  /// パック内でトリガーすべきイベントを取得
  static List<StoryPackEvent> getTriggeredEvents(
    String packId,
    String scenarioId,
    int currentYear,
    List<StoryPackEventProgress> eventProgress,
  ) {
    final packsEvents = PackEventService.getEventsInPack(packId);
    final triggeredEvents = <StoryPackEvent>[];

    for (final event in packsEvents) {
      final isAlreadyTriggered =
          eventProgress.any((p) => p.eventId == event.id && p.isTriggered);

      if (isAlreadyTriggered) {
        continue;
      }

      final matchesScenario = event.triggerScenarioIds.contains(scenarioId);
      final matchesYear = event.triggerYear == null || event.triggerYear == currentYear;

      if (matchesScenario && matchesYear) {
        triggeredEvents.add(event);
      }
    }

    return triggeredEvents..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// イベントを開始
  static StoryPackEventProgress startEvent(String eventId) {
    return StoryPackEventProgress(
      eventId: eventId,
      isTriggered: true,
      triggeredAt: DateTime.now(),
      selectedChoiceId: null,
      isCompleted: false,
    );
  }

  /// 選択肢から結果を計算
  static Map<String, dynamic> calculateOutcomes(
    String eventId,
    String choiceId,
  ) {
    return PackEventService.calculateEventImpact(eventId, choiceId);
  }

  /// イベント進捗を更新
  static StoryPackEventProgress completeEvent(
    StoryPackEventProgress progress,
    String choiceId,
  ) {
    return StoryPackEventProgress(
      eventId: progress.eventId,
      isTriggered: progress.isTriggered,
      triggeredAt: progress.triggeredAt,
      selectedChoiceId: choiceId,
      isCompleted: true,
    );
  }

  /// ゲームセッションにイベントの結果を適用
  static GameSession applyEventOutcomes(
    GameSession session,
    String eventId,
    String choiceId,
  ) {
    final outcomes = calculateOutcomes(eventId, choiceId);
    var updatedStatus = session.status;

    for (final entry in outcomes.entries) {
      final key = entry.key;
      final value = (entry.value as num).toDouble();

      switch (key) {
        case 'gdp':
          updatedStatus = updatedStatus.copyWith(
            gdp: (updatedStatus.gdp + value).clamp(0, double.infinity),
          );
        case 'satisfaction':
          updatedStatus = updatedStatus.copyWith(
            satisfaction: (updatedStatus.satisfaction + value).clamp(0, 100),
          );
        case 'stability':
          updatedStatus = updatedStatus.copyWith(
            stability: (updatedStatus.stability + value).clamp(0, 100),
          );
        case 'debt':
          // TODO: Add debt field to CountryStatus if needed
          break;
        case 'nationalPower':
          updatedStatus = updatedStatus.copyWith(
            nationalPower: (updatedStatus.nationalPower + value).clamp(0, 100),
          );
        case 'unemployment':
          updatedStatus = updatedStatus.copyWith(
            unemployment: (updatedStatus.unemployment + value).clamp(0, 100),
          );
      }
    }

    return session.copyWith(status: updatedStatus);
  }

  /// イベント進捗リストを更新
  static List<StoryPackEventProgress> updateEventProgress(
    List<StoryPackEventProgress> currentProgress,
    StoryPackEventProgress newProgress,
  ) {
    final updated = currentProgress.toList();
    final index = updated.indexWhere((p) => p.eventId == newProgress.eventId);

    if (index >= 0) {
      updated[index] = newProgress;
    } else {
      updated.add(newProgress);
    }

    return updated;
  }

  /// イベントチェーンの次のイベントを取得
  static StoryPackEvent? getNextEventInChain(String eventId) {
    return PackEventService.getFollowUpEvent(eventId);
  }

  /// パック内で完了したイベント数を計算
  static int getCompletedEventCountInPack(
    String packId,
    List<StoryPackEventProgress> eventProgress,
  ) {
    return eventProgress
        .where((p) =>
            p.isCompleted &&
            PackEventService.getEventById(p.eventId)?.packId == packId)
        .length;
  }

  /// パック内で発生したイベント数を計算
  static int getTriggeredEventCountInPack(
    String packId,
    List<StoryPackEventProgress> eventProgress,
  ) {
    return eventProgress
        .where((p) =>
            p.isTriggered &&
            PackEventService.getEventById(p.eventId)?.packId == packId)
        .length;
  }

  /// パック内の全イベント数
  static int getTotalEventCountInPack(String packId) {
    return PackEventService.getEventCountInPack(packId);
  }

  /// パック進捗統計
  static Map<String, int> getPackProgressStats(
    String packId,
    List<StoryPackEventProgress> eventProgress,
  ) {
    final total = getTotalEventCountInPack(packId);
    final triggered = getTriggeredEventCountInPack(packId, eventProgress);
    final completed = getCompletedEventCountInPack(packId, eventProgress);

    return {
      'total': total,
      'triggered': triggered,
      'completed': completed,
      'remaining': total - triggered,
    };
  }
}
