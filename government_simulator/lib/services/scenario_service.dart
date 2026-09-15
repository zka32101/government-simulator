/// シナリオ管理サービス
/// 複数の仮想国シナリオの提供と初期化

library;

import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/models/international_relations.dart';
import 'package:government_simulator/data/scenarios/ostia_scenario.dart';
import 'package:government_simulator/data/scenarios/amanda_scenario.dart';
import 'package:government_simulator/data/scenarios/islas_scenario.dart';
import 'package:government_simulator/data/scenarios/norsland_scenario.dart';
import 'package:government_simulator/data/scenarios/terranova_scenario.dart';

/// シナリオ管理サービス
class ScenarioService {
  /// 利用可能なすべてのシナリオ
  static final List<GameScenario> allScenarios = [
    ostiaScenario,
    amandaScenario,
    islasScenario,
    norslandScenario,
    terranovaScenario,
  ];

  /// シナリオIDからシナリオを取得
  static GameScenario? getScenarioById(String id) {
    try {
      return allScenarios.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 難易度別にシナリオを分類
  static List<GameScenario> getScenariosByDifficulty(String difficulty) {
    return allScenarios.where((s) => s.difficulty == difficulty).toList();
  }

  /// 地域別にシナリオを分類
  static List<GameScenario> getScenariosByRegion(String region) {
    return allScenarios.where((s) => s.region == region).toList();
  }

  /// シナリオからゲームセッション用の初期化データを生成
  /// 注意：既存のgame_sessionコンストラクタに対応するデータを返す
  static Map<String, dynamic> createGameSessionDataFromScenario(
    GameScenario scenario,
  ) {
    // 外交サービスの初期化（隣国との関係）
    final nationRelationships = _initializeNationRelationships(scenario);

    return {
      'scenarioId': scenario.id,
      'countryName': scenario.countryName,
      'economicSatisfaction': scenario.economicSatisfaction,
      'socialSatisfaction': scenario.socialSatisfaction,
      'securitySatisfaction': scenario.securitySatisfaction,
      'healthcareSatisfaction': scenario.healthcareSatisfaction,
      'nationalApproval': scenario.initialApproval,
      'budget': scenario.budget,
      'nationalDebt': scenario.nationalDebt,
      'nationRelationships': nationRelationships,
      'difficulty': scenario.difficulty,
    };
  }

  /// 国際関係ステータス文字列をパース
  static RelationshipStatus _parseRelationshipStatus(String status) {
    return switch (status) {
      '同盟国' || 'NATO同盟国' => RelationshipStatus.allied,
      '友好国' || '友好国・経済的主導国' || 'セキュリティ同盟国' ||
      '地域経済的リーダー' || '地域パートナー' || 'EU主要国' ||
      '北欧パートナー' => RelationshipStatus.cordial,
      '中立国（不安定）' || '中立国' || '新興経済的パートナー' ||
      '隣国（不安定）' || '経済的主導国・領土紛争国' ||
      '支配的な大国' => RelationshipStatus.neutral,
      '敵対国' || 'コカイン麻薬供給源' || '地政学的対立国' =>
        RelationshipStatus.hostile,
      _ => RelationshipStatus.neutral,
    };
  }

  /// シナリオから国家関係情報を初期化
  static Map<String, NationRelationship> _initializeNationRelationships(
    GameScenario scenario,
  ) {
    final relationships = <String, NationRelationship>{};

    for (final initial in scenario.initialNations) {
      // スタンディングスコアから relationshipStatus を決定
      final status = _parseRelationshipStatus(initial.relationship);

      relationships[initial.nationName] = NationRelationship(
        nationId: initial.nationName.toLowerCase().replaceAll(' ', '_'),
        nationName: initial.nationName,
        standingScore: initial.standingScore.toDouble(),
        isAlly: status == RelationshipStatus.allied,
        isAtWar: status == RelationshipStatus.enemy,
      );
    }

    return relationships;
  }

  /// セッションIDを生成
  static String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// シナリオの詳細情報を取得
  static String getScenarioDescription(GameScenario scenario) {
    return '''
【${scenario.countryName}】

地域：${scenario.region}
難易度：${scenario.difficulty}

📊 基本情報
- 人口：${scenario.population.toStringAsFixed(1)}百万人
- GDP：\$${scenario.gdp.toStringAsFixed(1)}兆
- 政治体制：${scenario.politicalSystem}
- 通貨：${scenario.currency}

📈 初期状態
- 承認度：${scenario.initialApproval.toStringAsFixed(1)}%
- 予算：\$${scenario.budget.toStringAsFixed(0)}百万
- 国債：\$${scenario.nationalDebt.toStringAsFixed(0)}十億

📖 背景
${scenario.historicalBackground}

⚠️ 現在の課題
${scenario.currentChallenges.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

💡 機会
${scenario.opportunities.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}
    ''';
  }

  /// シナリオの満足度比較を取得（easy, normal, hard）
  static Map<String, double> getSatisfactionComparison() {
    double avgEasy = 0;
    double avgNormal = 0;
    double avgHard = 0;

    final easyScenarios = getScenariosByDifficulty('easy');
    final normalScenarios = getScenariosByDifficulty('normal');
    final hardScenarios = getScenariosByDifficulty('hard');
    final veryHardScenarios =
        allScenarios.where((s) => s.difficulty == 'very_hard').toList();

    if (easyScenarios.isNotEmpty) {
      avgEasy = easyScenarios
              .map((s) =>
                  (s.economicSatisfaction +
                      s.socialSatisfaction +
                      s.securitySatisfaction +
                      s.healthcareSatisfaction) /
                  4)
              .reduce((a, b) => a + b) /
          easyScenarios.length;
    }

    if (normalScenarios.isNotEmpty) {
      avgNormal = normalScenarios
              .map((s) =>
                  (s.economicSatisfaction +
                      s.socialSatisfaction +
                      s.securitySatisfaction +
                      s.healthcareSatisfaction) /
                  4)
              .reduce((a, b) => a + b) /
          normalScenarios.length;
    }

    if (hardScenarios.isNotEmpty || veryHardScenarios.isNotEmpty) {
      final allHard = [...hardScenarios, ...veryHardScenarios];
      avgHard = allHard
              .map((s) =>
                  (s.economicSatisfaction +
                      s.socialSatisfaction +
                      s.securitySatisfaction +
                      s.healthcareSatisfaction) /
                  4)
              .reduce((a, b) => a + b) /
          allHard.length;
    }

    return {
      'easy': avgEasy,
      'normal': avgNormal,
      'hard': avgHard,
    };
  }
}
