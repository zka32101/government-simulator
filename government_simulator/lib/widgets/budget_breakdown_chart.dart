import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:government_simulator/models/budget_allocation.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 政府予算配分をパイチャートで表示するウィジェット
/// セクター別の予算配分を視覚的に理解でき、最大3セクターの詳細情報を表示
class BudgetBreakdownChart extends StatefulWidget {
  final BudgetAllocation budget;
  final void Function(BudgetSector)? onSectorTap;

  const BudgetBreakdownChart({
    Key? key,
    required this.budget,
    this.onSectorTap,
  }) : super(key: key);

  @override
  State<BudgetBreakdownChart> createState() => _BudgetBreakdownChartState();
}

class _BudgetBreakdownChartState extends State<BudgetBreakdownChart> {
  BudgetSector? _selectedSector;

  @override
  Widget build(BuildContext context) {
    // 予算額でソート（大きい順）
    final sortedSectors = widget.budget.sectorAllocations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 表示用データの準備（カラーマップを使用）
    final colors = _generateColors(sortedSectors.length);
    final pieChartData = _buildPieChartData(sortedSectors, colors);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // パイチャート
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: PieChart(pieChartData),
          ),
          const SizedBox(height: 24),

          // 凡例とセクター詳細
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '予算配分の詳細',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                  ),
                ),
                const SizedBox(height: 12),
                ...sortedSectors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sector = entry.value.key;
                  final percentage = entry.value.value;
                  final color = colors[index];
                  final budgetAmount = widget.budget.getBudgetForSector(sector);

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedSector = sector);
                      widget.onSectorTap?.call(sector);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedSector == sector
                            ? color.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedSector == sector
                              ? color
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          // カラーインジケーター
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // セクター情報
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sector.emoji,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        sector.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${budgetAmount.toStringAsFixed(1)}億円',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // パーセンテージ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // 総予算情報
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '総予算額',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.budget.totalBudget.toStringAsFixed(1)}億円',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.gold.withValues(alpha: 0.2),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '検証状況',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.budget.isValid ? '✅ 有効' : '⚠️ エラー',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.budget.isValid ? AppTheme.good : AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 選択セクターの詳細情報
          if (_selectedSector != null) ...[
            const SizedBox(height: 16),
            _buildSectorDetailPanel(_selectedSector!),
          ],
        ],
      ),
    );
  }

  /// セクター詳細パネルを構築
  Widget _buildSectorDetailPanel(BudgetSector sector) {
    final percentage = widget.budget.sectorAllocations[sector] ?? 0.0;
    final amount = widget.budget.getBudgetForSector(sector);
    final history = widget.budget.historicalAllocations[sector] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Text(
                sector.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sector.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '選択済み',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 配分情報
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '予算配分',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '予算額',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${amount.toStringAsFixed(1)}億円',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 過去の推移
          if (history.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '配分の推移',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history.asMap().entries.map((entry) {
                final idx = entry.key;
                final value = entry.value;
                final maxValue = history.fold(0.0, (max, v) => v > max ? v : max);
                final height = (value / (maxValue > 0 ? maxValue : 100)) * 40;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'P${idx + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// パイチャートデータを構築
  PieChartData _buildPieChartData(
    List<MapEntry<BudgetSector, double>> sectors,
    List<Color> colors,
  ) {
    final sections = sectors.asMap().entries.map((entry) {
      final index = entry.key;
      final sector = entry.value.key;
      final percentage = entry.value.value;
      final color = colors[index];

      return PieChartSectionData(
        value: percentage,
        title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChartData(sections: sections);
  }

  /// チャート用のカラーパレットを生成
  List<Color> _generateColors(int count) {
    final colors = [
      const Color(0xFF4CAF50), // 緑：社会保障
      const Color(0xFFE53935), // 赤：防衛
      const Color(0xFF1E88E5), // 青：教育
      const Color(0xFFFFA726), // 橙：インフラ
      const Color(0xFF7E57C2), // 紫：研究開発
      const Color(0xFF29B6F6), // 水色：環境
      const Color(0xFF66BB6A), // 薄い緑：農業
      const Color(0xFFAB47BC), // ピンク紫：経済政策
      const Color(0xFF78909C), // グレー：一般行政
      const Color(0xFFFF7043), // ディープオレンジ：債務返済
    ];

    // 要求数に応じて色を返す（足りなければリサイクル）
    return List.generate(count, (i) => colors[i % colors.length]);
  }
}
