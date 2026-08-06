import 'package:government_simulator/models/faction.dart';

/// 派閥への公約（二枚舌外交システム）。
/// 約束した派閥の支持率が一定ターン後に上昇していれば果たされ、
/// 下降・横ばいなら破約となり通常の3倍の支持率低下＋永続的な「嘘つき」評価を受ける。
class Promise {
  final String id;
  final Faction faction;
  final int madeAtDecisionCount;
  final int dueAtDecisionCount;
  final double supportAtPromiseTime;

  const Promise({
    required this.id,
    required this.faction,
    required this.madeAtDecisionCount,
    required this.dueAtDecisionCount,
    required this.supportAtPromiseTime,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'faction': faction.name,
        'madeAtDecisionCount': madeAtDecisionCount,
        'dueAtDecisionCount': dueAtDecisionCount,
        'supportAtPromiseTime': supportAtPromiseTime,
      };

  factory Promise.fromMap(Map<String, dynamic> map) => Promise(
        id: map['id'] ?? '',
        faction: Faction.values.firstWhere((f) => f.name == map['faction'],
            orElse: () => Faction.citizen),
        madeAtDecisionCount: map['madeAtDecisionCount'] ?? 0,
        dueAtDecisionCount: map['dueAtDecisionCount'] ?? 0,
        supportAtPromiseTime: (map['supportAtPromiseTime'] ?? 50).toDouble(),
      );
}

/// 公約解決の結果（果たされた／破られた）を表す。
class PromiseResolution {
  final Promise promise;
  final bool fulfilled;
  final String narrative;

  const PromiseResolution({
    required this.promise,
    required this.fulfilled,
    required this.narrative,
  });
}
