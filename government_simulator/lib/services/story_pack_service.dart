/// ストーリーパック管理サービス
/// パック内のシナリオ管理と進捗追跡

import 'package:government_simulator/models/story_pack.dart';
import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/services/scenario_service.dart';
import 'package:government_simulator/data/story_packs_data.dart';

/// ストーリーパック管理サービス
class StoryPackService {
  /// 全ストーリーパック
  static final List<StoryPack> allPacks = allStoryPacks;

  /// パックIDからパックを取得
  static StoryPack? getPackById(String packId) {
    try {
      return allPacks.firstWhere((p) => p.id == packId);
    } catch (e) {
      return null;
    }
  }

  /// パック内のシナリオ一覧を取得
  static List<GameScenario> getScenariosInPack(String packId) {
    final pack = getPackById(packId);
    if (pack == null) return [];

    return pack.scenarioIds
        .map((id) => ScenarioService.getScenarioById(id))
        .whereType<GameScenario>()
        .toList();
  }

  /// シナリオが属するパックを取得
  static StoryPack? getPackForScenario(String scenarioId) {
    try {
      return allPacks.firstWhere(
        (p) => p.scenarioIds.contains(scenarioId),
      );
    } catch (e) {
      return null;
    }
  }

  /// テーマ別にパックを分類
  static List<StoryPack> getPacksByTheme(String theme) {
    return allPacks.where((p) => p.theme == theme).toList();
  }

  /// 地域別にパックを分類
  static List<StoryPack> getPacksByRegion(String region) {
    return allPacks.where((p) => p.region == region).toList();
  }

  /// タグで検索
  static List<StoryPack> getPacksByTag(String tag) {
    return allPacks.where((p) => p.tags.contains(tag)).toList();
  }

  /// ロック状態でフィルタリング
  static List<StoryPack> getUnlockedPacks() {
    return allPacks.where((p) => !p.isLocked).toList();
  }

  /// 全ユニークテーマを取得
  static List<String> getAllThemes() {
    final themes = <String>{};
    for (final pack in allPacks) {
      themes.add(pack.theme);
    }
    return themes.toList();
  }

  /// 全ユニーク地域を取得
  static List<String> getAllRegions() {
    final regions = <String>{};
    for (final pack in allPacks) {
      regions.add(pack.region);
    }
    return regions.toList();
  }

  /// 全ユニークタグを取得
  static List<String> getAllTags() {
    final tags = <String>{};
    for (final pack in allPacks) {
      tags.addAll(pack.tags);
    }
    return tags.toList();
  }

  /// パック内のシナリオ数を取得
  static int getScenarioCountInPack(String packId) {
    final pack = getPackById(packId);
    return pack?.scenarioIds.length ?? 0;
  }

  /// パックの進捗（何シナリオが含まれているか）を取得
  static Map<String, int> getPackProgressStats(String packId) {
    final count = getScenarioCountInPack(packId);
    return {
      'total': count,
      'completed': 0, // 将来実装：ユーザーのシナリオ完了状況から計算
      'inProgress': 0,
      'notStarted': count,
    };
  }

  /// ディフィカルティ平均を計算
  static double getAverageDifficultyForPack(String packId) {
    final scenarios = getScenariosInPack(packId);
    if (scenarios.isEmpty) return 0.0;

    final difficulties = <double>[];
    for (final scenario in scenarios) {
      switch (scenario.difficulty) {
        case 'easy':
          difficulties.add(1.0);
        case 'normal':
          difficulties.add(2.0);
        case 'hard':
          difficulties.add(3.0);
        case 'very_hard':
          difficulties.add(4.0);
        default:
          difficulties.add(2.0);
      }
    }

    return difficulties.reduce((a, b) => a + b) / difficulties.length;
  }

  /// パック詳細情報を取得（パック、シナリオ、進捗情報を含む）
  static Map<String, dynamic> getPackDetailedInfo(String packId) {
    final pack = getPackById(packId);
    if (pack == null) return {};

    final scenarios = getScenariosInPack(packId);
    final progressStats = getPackProgressStats(packId);
    final avgDifficulty = getAverageDifficultyForPack(packId);

    return {
      'pack': pack.toMap(),
      'scenarios': scenarios.map((s) => {'id': s.id, 'name': s.countryName, 'difficulty': s.difficulty}).toList(),
      'progress': progressStats,
      'averageDifficulty': avgDifficulty,
      'scenarioCount': scenarios.length,
    };
  }
}
