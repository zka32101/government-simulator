/// 内閣の大臣。それぞれ専門分野の政策結果に応じて忠誠度が変動し、
/// 著しく信頼を失うと隠しクーデター（裏切り）イベントが発生する。
enum MinisterRole {
  finance, // 財務大臣
  defense, // 国防大臣
  interior, // 内務大臣
  foreign, // 外務大臣
  environment, // 環境大臣
}

extension MinisterRoleExt on MinisterRole {
  String get label {
    switch (this) {
      case MinisterRole.finance:
        return '財務大臣';
      case MinisterRole.defense:
        return '国防大臣';
      case MinisterRole.interior:
        return '内務大臣';
      case MinisterRole.foreign:
        return '外務大臣';
      case MinisterRole.environment:
        return '環境大臣';
    }
  }

  String get emoji {
    switch (this) {
      case MinisterRole.finance:
        return '💰';
      case MinisterRole.defense:
        return '🎖️';
      case MinisterRole.interior:
        return '🏠';
      case MinisterRole.foreign:
        return '🌐';
      case MinisterRole.environment:
        return '🌿';
    }
  }

  /// AI生成キャラクター画像のアセットパス
  String get imagePath => 'assets/images/ministers/minister_$name.png';

  /// 裏切り発覚時のナラティブ
  String betrayalNarrative(String countryName) {
    switch (this) {
      case MinisterRole.finance:
        return '$label が国庫資金を横領し、国外へ逃亡した。経済界に激震が走る。';
      case MinisterRole.defense:
        return '$label が水面下でクーデターの根回しを進めていたことが発覚した。';
      case MinisterRole.interior:
        return '$label が汚職スキャンダルで失脚。国内行政に混乱が広がっている。';
      case MinisterRole.foreign:
        return '$label が他国と密約を結んでいたことが暴露され、外交的信用が失墜した。';
      case MinisterRole.environment:
        return '$label が企業からの贈賄を受け取り環境規制を骨抜きにしていたと判明した。';
    }
  }
}

/// 内閣全体の忠誠度状態。
class Cabinet {
  final Map<MinisterRole, double> loyalty; // 0-100
  final Set<MinisterRole> betrayed; // 一度裏切りが発覚した大臣（再発火防止）

  const Cabinet({required this.loyalty, this.betrayed = const {}});

  factory Cabinet.initial() => const Cabinet(loyalty: {
        MinisterRole.finance: 60,
        MinisterRole.defense: 60,
        MinisterRole.interior: 60,
        MinisterRole.foreign: 60,
        MinisterRole.environment: 60,
      });

  double of(MinisterRole role) => loyalty[role] ?? 60;

  /// 最も忠誠度が低い大臣（まだ裏切っていない中で）
  MapEntry<MinisterRole, double>? get mostDisloyal {
    final candidates =
        loyalty.entries.where((e) => !betrayed.contains(e.key)).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.value.compareTo(b.value));
    return candidates.first;
  }

  Cabinet applyDeltas(Map<MinisterRole, double> deltas) {
    final next = Map<MinisterRole, double>.from(loyalty);
    deltas.forEach((role, d) {
      next[role] = ((next[role] ?? 60) + d).clamp(0, 100).toDouble();
    });
    return Cabinet(loyalty: next, betrayed: betrayed);
  }

  Cabinet markBetrayed(MinisterRole role) {
    return Cabinet(loyalty: loyalty, betrayed: {...betrayed, role});
  }

  Map<String, dynamic> toMap() => {
        'loyalty': loyalty.map((k, v) => MapEntry(k.name, v)),
        'betrayed': betrayed.map((r) => r.name).toList(),
      };

  factory Cabinet.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Cabinet.initial();
    final loyaltyMap = <MinisterRole, double>{};
    final rawLoyalty = map['loyalty'] as Map<String, dynamic>?;
    for (final role in MinisterRole.values) {
      loyaltyMap[role] = (rawLoyalty?[role.name] ?? 60).toDouble();
    }
    final betrayedList = (map['betrayed'] as List?)
            ?.map((s) => MinisterRole.values.firstWhere((r) => r.name == s,
                orElse: () => MinisterRole.finance))
            .toSet() ??
        <MinisterRole>{};
    return Cabinet(loyalty: loyaltyMap, betrayed: betrayedList);
  }
}
