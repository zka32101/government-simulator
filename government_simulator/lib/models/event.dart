import 'package:government_simulator/models/faction.dart';

class GameEvent {
  final String id;
  final String title;
  final String description;
  final List<Choice> choices;
  final EventCategory category;
  final int weight; // イベント出現確率の重み
  final bool isRandom; // ランダムイベントか固定イベントか

  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
    required this.category,
    this.weight = 1,
    this.isRandom = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'choices': choices.map((c) => c.toMap()).toList(),
      'category': category.toString(),
      'weight': weight,
      'isRandom': isRandom,
    };
  }

  factory GameEvent.fromMap(Map<String, dynamic> map) {
    return GameEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      choices: (map['choices'] as List?)
              ?.map((c) => Choice.fromMap(c))
              .toList() ??
          [],
      category: EventCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => EventCategory.economic,
      ),
      weight: map['weight'] ?? 1,
      isRandom: map['isRandom'] ?? true,
    );
  }
}

class Choice {
  final String id;
  final String text;
  final String shortDescription; // UI表示用の簡潔な説明
  final Impact impact; // 選択の影響

  /// この選択が特定の派閥への公約である場合に設定する（二枚舌外交システム）。
  /// 一定ターン後、当該派閥の支持率が上昇していれば公約は果たされ、
  /// 横ばい・下降なら公約は破られる。
  final Faction? promiseTarget;

  const Choice({
    required this.id,
    required this.text,
    required this.shortDescription,
    required this.impact,
    this.promiseTarget,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'shortDescription': shortDescription,
      'impact': impact.toMap(),
      'promiseTarget': promiseTarget?.name,
    };
  }

  factory Choice.fromMap(Map<String, dynamic> map) {
    return Choice(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      impact: map['impact'] != null ? Impact.fromMap(map['impact']) : Impact(),
      promiseTarget: map['promiseTarget'] != null
          ? Faction.values.firstWhere((f) => f.name == map['promiseTarget'],
              orElse: () => Faction.citizen)
          : null,
    );
  }
}

// 選択肢の影響を表現するモデル（ゲーム性を高めるため複雑に）
class Impact {
  final double gdpChange; // 変化率 (%)
  final double unemploymentChange; // 変化率
  final double satisfactionChange; // 絶対値 (-100 to 100)
  final double nationalPowerChange; // 絶対値
  final double inflationChange; // 変化率
  final double stabilityChange; // 絶対値

  // 遅延効果（月単位）
  final Map<int, ImpactDelay> delayedEffects;

  // ランダムイベント発生確率
  final double criticalEventChance; // 0.0-1.0

  const Impact({
    this.gdpChange = 0.0,
    this.unemploymentChange = 0.0,
    this.satisfactionChange = 0.0,
    this.nationalPowerChange = 0.0,
    this.inflationChange = 0.0,
    this.stabilityChange = 0.0,
    this.delayedEffects = const {},
    this.criticalEventChance = 0.0,
  });

  // 影響の"大きさ"を計算（UI表示用）
  double get magnitude {
    return (gdpChange.abs() +
            unemploymentChange.abs() +
            satisfactionChange.abs() +
            nationalPowerChange.abs()) /
        4;
  }

  // 影響の方向（正: 好影響、負: 悪影響）
  double get direction {
    final positive = (gdpChange > 0 ? 1 : 0) +
        (unemploymentChange < 0 ? 1 : 0) +
        (satisfactionChange > 0 ? 1 : 0);
    final negative = (gdpChange < 0 ? 1 : 0) +
        (unemploymentChange > 0 ? 1 : 0) +
        (satisfactionChange < 0 ? 1 : 0);
    return positive - negative.toDouble();
  }

  // 影響タイプの分類
  List<ImpactType> get types {
    final types = <ImpactType>[];
    if (gdpChange != 0) types.add(ImpactType.economic);
    if (unemploymentChange != 0) types.add(ImpactType.employment);
    if (satisfactionChange != 0) types.add(ImpactType.social);
    if (stabilityChange != 0) types.add(ImpactType.stability);
    return types;
  }

  Map<String, dynamic> toMap() {
    return {
      'gdpChange': gdpChange,
      'unemploymentChange': unemploymentChange,
      'satisfactionChange': satisfactionChange,
      'nationalPowerChange': nationalPowerChange,
      'inflationChange': inflationChange,
      'stabilityChange': stabilityChange,
      'delayedEffects': delayedEffects.map((k, v) => MapEntry(k.toString(), v.toMap())),
      'criticalEventChance': criticalEventChance,
    };
  }

  factory Impact.fromMap(Map<String, dynamic> map) {
    final delayedEffects = <int, ImpactDelay>{};
    if (map['delayedEffects'] != null) {
      (map['delayedEffects'] as Map).forEach((key, value) {
        delayedEffects[int.parse(key)] = ImpactDelay.fromMap(value);
      });
    }

    return Impact(
      gdpChange: (map['gdpChange'] ?? 0.0).toDouble(),
      unemploymentChange: (map['unemploymentChange'] ?? 0.0).toDouble(),
      satisfactionChange: (map['satisfactionChange'] ?? 0.0).toDouble(),
      nationalPowerChange: (map['nationalPowerChange'] ?? 0.0).toDouble(),
      inflationChange: (map['inflationChange'] ?? 0.0).toDouble(),
      stabilityChange: (map['stabilityChange'] ?? 0.0).toDouble(),
      delayedEffects: delayedEffects,
      criticalEventChance: (map['criticalEventChance'] ?? 0.0).toDouble(),
    );
  }
}

// 遅延効果（例：政策が数ヶ月後に効果を示す）
class ImpactDelay {
  final int monthsLater;
  final Impact impact;

  const ImpactDelay({
    required this.monthsLater,
    required this.impact,
  });

  Map<String, dynamic> toMap() {
    return {
      'monthsLater': monthsLater,
      'impact': impact.toMap(),
    };
  }

  factory ImpactDelay.fromMap(Map<String, dynamic> map) {
    return ImpactDelay(
      monthsLater: map['monthsLater'] ?? 0,
      impact: map['impact'] != null ? Impact.fromMap(map['impact']) : Impact(),
    );
  }
}

enum EventCategory {
  economic('経済'),
  employment('雇用'),
  social('社会'),
  political('政治'),
  environmental('環境'),
  military('軍事'),
  external('外部ショック');

  final String label;

  const EventCategory(this.label);
}

enum ImpactType {
  economic('経済'),
  employment('雇用'),
  social('社会'),
  stability('安定');

  final String label;

  const ImpactType(this.label);
}

// ゲーム性を高めるためのイベント生成パターン
class EventPattern {
  static List<GameEvent> getInitialEvents() {
    return [
      GameEvent(
        id: 'event_01_tax_debate',
        title: '増税か減税か',
        description: '経済状況が議論を呼んでいます。\n国庫収入を増やすか、国民の負担を軽くするか。',
        category: EventCategory.economic,
        choices: [
          Choice(
            id: 'choice_01_increase_tax',
            text: '増税する',
            shortDescription: '国庫収入↑ | 国民満足度↓',
            impact: Impact(
              gdpChange: -0.5,
              satisfactionChange: -15,
              stabilityChange: 5,
            ),
          ),
          Choice(
            id: 'choice_01_decrease_tax',
            text: '減税する',
            shortDescription: '国庫収入↓ | 国民満足度↑',
            impact: Impact(
              gdpChange: 1.5,
              satisfactionChange: 20,
              stabilityChange: -10,
            ),
          ),
          Choice(
            id: 'choice_01_neutral',
            text: '現状維持',
            shortDescription: '影響なし',
            impact: Impact(),
          ),
        ],
        weight: 3,
      ),
      GameEvent(
        id: 'event_02_unemployment_crisis',
        title: '失業率上昇',
        description: '産業の自動化が加速し、失業者が増加しています。\n対策が必要です。',
        category: EventCategory.employment,
        choices: [
          Choice(
            id: 'choice_02_public_works',
            text: '公共事業を実施',
            shortDescription: '失業↓ | 支出増加',
            impact: Impact(
              unemploymentChange: -3.0,
              gdpChange: 1.0,
              satisfactionChange: 10,
            ),
          ),
          Choice(
            id: 'choice_02_education',
            text: '職業訓練を強化',
            shortDescription: '長期的な改善 | 短期効果低',
            impact: Impact(
              unemploymentChange: -1.0,
              satisfactionChange: 5,
              stabilityChange: 8,
            ),
          ),
        ],
        weight: 2,
      ),
    ];
  }
}
