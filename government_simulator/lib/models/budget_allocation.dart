/// 政府予算配分を表現するモデル
/// 国家の歳出をセクター別に分類し、政策による予算シフトの影響を可視化する
class BudgetAllocation {
  /// 各セクターの予算配分（パーセンテージ）。合計は常に100%
  final Map<BudgetSector, double> sectorAllocations;

  /// 予算の総額（億円単位）。GDPに基づいて計算される
  final double totalBudget;

  /// 各セクターの過去数期間の推移（分析用）
  final Map<BudgetSector, List<double>> historicalAllocations;

  const BudgetAllocation({
    required this.sectorAllocations,
    required this.totalBudget,
    this.historicalAllocations = const {},
  });

  /// デフォルトの予算配分を作成（政治的にバランスの取れた配分）
  factory BudgetAllocation.initial({
    required double gdp,
  }) {
    return BudgetAllocation(
      sectorAllocations: {
        BudgetSector.socialWelfare: 25.0, // 社会保障（年金・医療）
        BudgetSector.defense: 3.0, // 防衛
        BudgetSector.education: 4.0, // 教育
        BudgetSector.infrastructure: 8.0, // インフラ
        BudgetSector.research: 1.5, // 研究開発
        BudgetSector.environment: 2.0, // 環境
        BudgetSector.agriculture: 1.5, // 農業
        BudgetSector.economy: 10.0, // 経済政策（雇用対策など）
        BudgetSector.administration: 5.5, // 一般行政
        BudgetSector.debt: 40.0, // 債務返済（利払い・償還）
      },
      totalBudget: gdp / 2, // 予算規模 ≈ GDP の 50%（現実に近い）
    );
  }

  /// 指定されたセクターの実際の予算額を取得（単位：億円）
  double getBudgetForSector(BudgetSector sector) {
    final percentage = sectorAllocations[sector] ?? 0.0;
    return totalBudget * (percentage / 100);
  }

  /// 総予算の検証（常に100%になるべき）
  bool get isValid {
    final total = sectorAllocations.values.fold(0.0, (sum, val) => sum + val);
    return (total - 100.0).abs() < 0.1; // 浮動小数点の誤差を許容
  }

  /// 特定セクターの予算を増減させた新しいBudgetAllocationを作成
  BudgetAllocation adjustSector(BudgetSector sector, double percentageChange) {
    if (percentageChange == 0) return this;

    final newAllocations = Map<BudgetSector, double>.from(sectorAllocations);

    // セクターの新しい配分を計算
    final currentAllocation = newAllocations[sector] ?? 0.0;
    final newAllocation = (currentAllocation + percentageChange).clamp(0.0, 100.0);
    final actualChange = newAllocation - currentAllocation;

    newAllocations[sector] = newAllocation;

    // 他のセクターから成比例で予算をシフト
    if (actualChange != 0) {
      final otherSectors = BudgetSector.values
          .where((s) => s != sector)
          .toList();

      if (otherSectors.isNotEmpty) {
        // 予算追加時は全セクターから等比例に削減、
        // 予算削減時は全セクターに等比例に配分
        final adjustmentPerSector = actualChange / otherSectors.length;
        for (final s in otherSectors) {
          final current = newAllocations[s] ?? 0.0;
          newAllocations[s] = (current - adjustmentPerSector).clamp(0.0, 100.0);
        }
      }
    }

    // 正規化（丸め誤差を補正）
    _normalizeAllocations(newAllocations);

    return BudgetAllocation(
      sectorAllocations: newAllocations,
      totalBudget: totalBudget,
      historicalAllocations: historicalAllocations,
    );
  }

  /// 複数セクターの予算を一度に調整
  BudgetAllocation adjustMultipleSectors(
    Map<BudgetSector, double> changes,
  ) {
    var result = this;
    for (final entry in changes.entries) {
      result = result.adjustSector(entry.key, entry.value);
    }
    return result;
  }

  /// 配分を正規化（合計が100%になるよう調整）
  static void _normalizeAllocations(Map<BudgetSector, double> allocations) {
    final total = allocations.values.fold(0.0, (sum, val) => sum + val);
    if (total <= 0) return;

    // 全セクターをスケール
    for (final sector in allocations.keys) {
      allocations[sector] = allocations[sector]! * (100.0 / total);
    }
  }

  /// 過去の推移を追跡（新しいスナップショットを記録）
  BudgetAllocation recordSnapshot() {
    final newHistorical = Map<BudgetSector, List<double>>.from(historicalAllocations);
    for (final sector in BudgetSector.values) {
      final allocation = sectorAllocations[sector] ?? 0.0;
      newHistorical[sector] ??= [];
      if ((newHistorical[sector]?.length ?? 0) >= 12) {
        // 12期間以上は古いデータを削除
        newHistorical[sector] = newHistorical[sector]!.sublist(1);
      }
      newHistorical[sector]!.add(allocation);
    }

    return BudgetAllocation(
      sectorAllocations: sectorAllocations,
      totalBudget: totalBudget,
      historicalAllocations: newHistorical,
    );
  }

  BudgetAllocation copyWith({
    Map<BudgetSector, double>? sectorAllocations,
    double? totalBudget,
    Map<BudgetSector, List<double>>? historicalAllocations,
  }) {
    return BudgetAllocation(
      sectorAllocations: sectorAllocations ?? this.sectorAllocations,
      totalBudget: totalBudget ?? this.totalBudget,
      historicalAllocations: historicalAllocations ?? this.historicalAllocations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectorAllocations': sectorAllocations
          .map((key, value) => MapEntry(key.toString(), value)),
      'totalBudget': totalBudget,
      'historicalAllocations': historicalAllocations.map((key, value) =>
          MapEntry(key.toString(), value)),
    };
  }

  factory BudgetAllocation.fromMap(Map<String, dynamic> map) {
    final allocations = <BudgetSector, double>{};
    if (map['sectorAllocations'] != null) {
      (map['sectorAllocations'] as Map).forEach((key, value) {
        final sector = BudgetSector.values.firstWhere(
          (s) => s.toString() == key,
          orElse: () => BudgetSector.economy,
        );
        allocations[sector] = (value as num).toDouble();
      });
    }

    final historical = <BudgetSector, List<double>>{};
    if (map['historicalAllocations'] != null) {
      (map['historicalAllocations'] as Map).forEach((key, value) {
        final sector = BudgetSector.values.firstWhere(
          (s) => s.toString() == key,
          orElse: () => BudgetSector.economy,
        );
        historical[sector] = List<double>.from(
          (value as List).cast<num>().map((v) => v.toDouble()),
        );
      });
    }

    return BudgetAllocation(
      sectorAllocations: allocations,
      totalBudget: (map['totalBudget'] ?? 0.0).toDouble(),
      historicalAllocations: historical,
    );
  }
}

/// 政府予算のセクター（支出分類）
enum BudgetSector {
  socialWelfare('社会保障', '👨‍👩‍👧‍👦'), // 年金・医療・福祉
  defense('防衛', '🪖'), // 防衛予算
  education('教育', '📚'), // 教育・人材育成
  infrastructure('インフラ', '🏗️'), // 公共事業・インフラ整備
  research('研究開発', '🔬'), // 科学・技術研究
  environment('環境', '🌍'), // 環境対策・エネルギー
  agriculture('農業', '🌾'), // 農業・漁業
  economy('経済政策', '💼'), // 雇用対策・産業政策
  administration('一般行政', '🏛️'), // 一般行政費
  debt('債務返済', '💳'); // 国債償還・利払い

  final String label;
  final String emoji;

  const BudgetSector(this.label, this.emoji);
}
