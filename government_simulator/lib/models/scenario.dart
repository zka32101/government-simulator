/// ゲームシナリオモデル
/// 複数の仮想国シナリオを定義・管理

import 'package:government_simulator/models/crisis.dart';

/// ゲームシナリオ
class GameScenario {
  final String id;
  final String countryName;
  final String region;
  final String description;
  final String difficulty; // easy, normal, hard
  final double population; // 百万単位
  final double gdp; // 十億ドル単位
  final String politicalSystem;
  final String currency;

  /// 初期ゲーム状態
  final double initialApproval;
  final double economicSatisfaction;
  final double socialSatisfaction;
  final double securitySatisfaction;
  final double healthcareSatisfaction;
  final double budget; // 初期予算（百万ドル）
  final double nationalDebt; // 国債（十億ドル）

  /// シナリオの背景・歴史
  final String historicalBackground;
  final List<String> currentChallenges;
  final List<String> opportunities;

  /// キャラクター
  final List<ScenarioCharacter> characters;

  /// 隣国・国際関係
  final List<InitialNationRelation> initialNations;

  /// ストーリーアーク
  final List<StoryArc> storyArcs;

  /// 固有の危機タイプ
  final List<CrisisType> uniqueCrises;

  const GameScenario({
    required this.id,
    required this.countryName,
    required this.region,
    required this.description,
    required this.difficulty,
    required this.population,
    required this.gdp,
    required this.politicalSystem,
    required this.currency,
    required this.initialApproval,
    required this.economicSatisfaction,
    required this.socialSatisfaction,
    required this.securitySatisfaction,
    required this.healthcareSatisfaction,
    required this.budget,
    required this.nationalDebt,
    required this.historicalBackground,
    required this.currentChallenges,
    required this.opportunities,
    required this.characters,
    required this.initialNations,
    required this.storyArcs,
    required this.uniqueCrises,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'countryName': countryName,
      'region': region,
      'description': description,
      'difficulty': difficulty,
      'population': population,
      'gdp': gdp,
      'politicalSystem': politicalSystem,
      'currency': currency,
      'initialApproval': initialApproval,
      'economicSatisfaction': economicSatisfaction,
      'socialSatisfaction': socialSatisfaction,
      'securitySatisfaction': securitySatisfaction,
      'healthcareSatisfaction': healthcareSatisfaction,
      'budget': budget,
      'nationalDebt': nationalDebt,
      'historicalBackground': historicalBackground,
      'currentChallenges': currentChallenges,
      'opportunities': opportunities,
      'characters': characters.map((c) => c.toMap()).toList(),
      'initialNations': initialNations.map((n) => n.toMap()).toList(),
      'storyArcs': storyArcs.map((s) => s.toMap()).toList(),
      'uniqueCrises': uniqueCrises.map((c) => c.toString().split('.').last).toList(),
    };
  }
}

/// シナリオのキャラクター
class ScenarioCharacter {
  final String name;
  final String title;
  final String position; // 内閣・野党・利益団体など
  final String stance; // 改革派・保守派・中立など
  final double influence; // 0-1: 影響力
  final String description;
  final String? faction; // 派閥名

  const ScenarioCharacter({
    required this.name,
    required this.title,
    required this.position,
    required this.stance,
    required this.influence,
    required this.description,
    this.faction,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'position': position,
      'stance': stance,
      'influence': influence,
      'description': description,
      'faction': faction,
    };
  }
}

/// 初期国際関係
class InitialNationRelation {
  final String nationName;
  final String relationship; // 同盟国・友好国・中立・敵対国など
  final int standingScore; // -100 ～ 100
  final String description;
  final String? sharedInterests; // 共通利益
  final String? conflicts; // 対立点

  const InitialNationRelation({
    required this.nationName,
    required this.relationship,
    required this.standingScore,
    required this.description,
    this.sharedInterests,
    this.conflicts,
  });

  Map<String, dynamic> toMap() {
    return {
      'nationName': nationName,
      'relationship': relationship,
      'standingScore': standingScore,
      'description': description,
      'sharedInterests': sharedInterests,
      'conflicts': conflicts,
    };
  }
}

/// ストーリーアーク
class StoryArc {
  final String title;
  final String description;
  final String theme; // economic, military, diplomatic, domestic など
  final List<String> keyEvents; // このアークで起こりうる主要イベント
  final int priority; // 優先度（1-5）

  const StoryArc({
    required this.title,
    required this.description,
    required this.theme,
    required this.keyEvents,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'theme': theme,
      'keyEvents': keyEvents,
      'priority': priority,
    };
  }
}
