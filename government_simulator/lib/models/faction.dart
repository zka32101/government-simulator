import 'package:flutter/material.dart';

/// 国内の主要派閥。プレイヤーの選択が各派閥の好感度に影響する。
enum Faction {
  military, // 軍部
  business, // 財界
  labor, // 労働者
  citizen, // 市民（リベラル/環境）
}

extension FactionExt on Faction {
  String get label {
    switch (this) {
      case Faction.military:
        return '軍部';
      case Faction.business:
        return '財界';
      case Faction.labor:
        return '労働者';
      case Faction.citizen:
        return '市民';
    }
  }

  String get emoji {
    switch (this) {
      case Faction.military:
        return '🎖️';
      case Faction.business:
        return '💼';
      case Faction.labor:
        return '🔧';
      case Faction.citizen:
        return '🧑‍🤝‍🧑';
    }
  }

  Color get color {
    switch (this) {
      case Faction.military:
        return const Color(0xFF6D4C41); // 茶
      case Faction.business:
        return const Color(0xFF1565C0); // 青
      case Faction.labor:
        return const Color(0xFFEF6C00); // オレンジ
      case Faction.citizen:
        return const Color(0xFF2E7D32); // 緑
    }
  }

  String get description {
    switch (this) {
      case Faction.military:
        return '国防と秩序を重んじる。防衛費削減や弱腰外交を嫌う。';
      case Faction.business:
        return '経済成長と自由市場を求める。増税や規制強化に反発する。';
      case Faction.labor:
        return '雇用と労働者の権利を守る。緊縮や賃下げに激しく抗議する。';
      case Faction.citizen:
        return '環境・人権・福祉を重視する。汚職や強権政治を許さない。';
    }
  }
}

/// 各派閥の支持率（0-100）を保持する。
class FactionSupport {
  final Map<Faction, double> support;

  /// 一度でも公約を破った相手の派閥（永続的な「嘘つき」評価）。
  final Set<Faction> liarFlags;

  const FactionSupport(this.support, {this.liarFlags = const {}});

  factory FactionSupport.initial() => const FactionSupport({
        Faction.military: 50,
        Faction.business: 50,
        Faction.labor: 50,
        Faction.citizen: 50,
      });

  double of(Faction f) => support[f] ?? 50;

  bool isLiarTo(Faction f) => liarFlags.contains(f);

  /// 最も敵対的な派閥（支持率最低）
  MapEntry<Faction, double> get mostHostile {
    var entry = support.entries.first;
    for (final e in support.entries) {
      if (e.value < entry.value) entry = e;
    }
    return entry;
  }

  /// 平均支持率
  double get average =>
      support.values.fold(0.0, (s, v) => s + v) / support.length;

  /// クーデター/革命リスク（最低支持率が低いほど高い）
  bool get isCoupRisk => mostHostile.value < 15;

  FactionSupport applyDeltas(Map<Faction, double> deltas) {
    final next = Map<Faction, double>.from(support);
    deltas.forEach((f, d) {
      next[f] = ((next[f] ?? 50) + d).clamp(0, 100).toDouble();
    });
    return FactionSupport(next, liarFlags: liarFlags);
  }

  /// 公約を破った際に呼ぶ。以後この派閥からは「嘘つき」として扱われる。
  FactionSupport markLiar(Faction f) {
    return FactionSupport(support, liarFlags: {...liarFlags, f});
  }

  Map<String, dynamic> toMap() => {
        'support': support.map((k, v) => MapEntry(k.name, v)),
        'liarFlags': liarFlags.map((f) => f.name).toList(),
      };

  factory FactionSupport.fromMap(Map<String, dynamic>? map) {
    if (map == null) return FactionSupport.initial();
    // 旧フォーマット（{faction: value} を直接持つマップ）との後方互換。
    final rawSupport = (map['support'] as Map<String, dynamic>?) ?? map;
    final result = <Faction, double>{};
    for (final f in Faction.values) {
      result[f] = (rawSupport[f.name] ?? 50).toDouble();
    }
    final liarFlags = (map['liarFlags'] as List?)
            ?.map((s) => Faction.values.firstWhere((f) => f.name == s,
                orElse: () => Faction.citizen))
            .toSet() ??
        <Faction>{};
    return FactionSupport(result, liarFlags: liarFlags);
  }
}
