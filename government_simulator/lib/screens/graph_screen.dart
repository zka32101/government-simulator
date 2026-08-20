import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/utils/constants.dart';

class GraphScreen extends StatefulWidget {
  final DecisionHistory decisionHistory;

  const GraphScreen({
    Key? key,
    required this.decisionHistory,
  }) : super(key: key);

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late String _selectedStat;

  @override
  void initState() {
    super.initState();
    _selectedStat = 'gdp';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 国家の推移'),
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 統計情報カード
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📈 ゲーム統計',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      _StatRow(
                        label: '総意思決定数',
                        value: '${widget.decisionHistory.decisions.length}',
                        icon: '🎯',
                      ),
                      _StatRow(
                        label: '成功率',
                        value: '${widget.decisionHistory.successRate.toStringAsFixed(1)}%',
                        icon: '✅',
                      ),
                      _StatRow(
                        label: '平均インパクトスコア',
                        value: '${widget.decisionHistory.averageImpactScore.toStringAsFixed(1)}',
                        icon: '📊',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // グラフ選択ボタン
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _GraphSelectButton(
                      label: 'GDP',
                      icon: '💰',
                      isSelected: _selectedStat == 'gdp',
                      onPressed: () => setState(() => _selectedStat = 'gdp'),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    _GraphSelectButton(
                      label: '失業率',
                      icon: '👥',
                      isSelected: _selectedStat == 'unemployment',
                      onPressed: () =>
                          setState(() => _selectedStat = 'unemployment'),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    _GraphSelectButton(
                      label: '満足度',
                      icon: '😊',
                      isSelected: _selectedStat == 'satisfaction',
                      onPressed: () =>
                          setState(() => _selectedStat = 'satisfaction'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // グラフ表示
              if (widget.decisionHistory.decisions.isNotEmpty)
                _buildGraph()
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    child: Center(
                      child: Text(
                        'データがまだありません。\n意思決定を重ねると推移が表示されます。',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraph() {
    final decisions = widget.decisionHistory.decisions.toList()
      ..sort((a, b) => a.decidedAt.compareTo(b.decidedAt));

    if (decisions.isEmpty) {
      return const SizedBox.shrink();
    }

    List<FlSpot> spots = [];
    if (_selectedStat == 'gdp') {
      for (int i = 0; i < decisions.length; i++) {
        spots.add(FlSpot(i.toDouble(), decisions[i].afterStatus.gdp));
      }
    } else if (_selectedStat == 'unemployment') {
      for (int i = 0; i < decisions.length; i++) {
        spots.add(FlSpot(i.toDouble(), decisions[i].afterStatus.unemployment));
      }
    } else if (_selectedStat == 'satisfaction') {
      for (int i = 0; i < decisions.length; i++) {
        spots.add(
            FlSpot(i.toDouble(), decisions[i].afterStatus.satisfaction));
      }
    }

    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }

    final rawMinY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final rawMaxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    // 全ての値が同じ（決定が1件だけ、または選択中の指標が変化していない）
    // 場合 maxY - minY == 0 になり、fl_chart に interval: 0 を渡すと
    // アサーションで落ちるため、その場合は 1.0 にフォールバックする。
    final horizontalInterval =
        (rawMaxY - rawMinY) > 0 ? (rawMaxY - rawMinY) / 5 : 1.0;
    // minY/maxY 自体も *0.9/*1.1 の乗算パディングでは、値がちょうど 0
    // （例：失業率0%や決定1件のみの場合）だと minY == maxY == 0 の
    // ままとなり、Y軸の描画範囲がゼロ幅になってしまう。全て同値のときは
    // 固定幅（±1、最低でも上下1ずつ）でパディングする。
    final minY = rawMaxY > rawMinY ? rawMinY * 0.9 : rawMinY - 1;
    final maxY = rawMaxY > rawMinY ? rawMaxY * 1.1 : rawMaxY + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: horizontalInterval,
                verticalInterval: (decisions.length / 5).ceil().toDouble(),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: (decisions.length / 5).ceil().toDouble(),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < decisions.length) {
                        return Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              minX: 0,
              // decisions.length == 1 のとき (length - 1) == 0 となり
              // minX と一致してX軸の描画範囲がゼロ幅になる
              // （fl_chart 内部でのゼロ除算につながる）ため、
              // 最低でも 1.0 を確保する。
              maxX: decisions.length > 1
                  ? (decisions.length - 1).toDouble()
                  : 1.0,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Color(VisualConstants.colorPrimary),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Color(VisualConstants.colorPrimary),
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Color(VisualConstants.colorPrimary).withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppConstants.paddingS),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _GraphSelectButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const _GraphSelectButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Color(VisualConstants.colorPrimary)
            : Colors.grey[300],
        foregroundColor:
            isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
      ),
      child: Text('$icon $label'),
    );
  }
}
