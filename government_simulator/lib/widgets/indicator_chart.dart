import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:government_simulator/models/indicator_history.dart';
import 'package:government_simulator/utils/constants.dart';

/// 国家指標のトレンド表示用チャート。
/// 折れ線グラフで指定された指標の推移を可視化する。
class IndicatorChart extends StatefulWidget {
  /// 表示対象の指標キー。'gdp', 'unemployment', 'satisfaction', 'nationalPower',
  /// 'inflationRate', 'publicDebt', 'stability' のいずれか。
  final String indicatorKey;

  /// 指標の日本語表示名。
  final String indicatorLabel;

  /// 指標の単位。例: '%', 'B', スペース等。
  final String unit;

  /// 指標のカラー。
  final Color chartColor;

  /// 履歴スナップショットのリスト。年の昇順であることを想定。
  final List<IndicatorSnapshot> history;

  /// タップ時のコールバック（詳細情報表示用）。
  final Function(IndicatorSnapshot snapshot)? onTapDataPoint;

  const IndicatorChart({
    Key? key,
    required this.indicatorKey,
    required this.indicatorLabel,
    required this.unit,
    required this.chartColor,
    required this.history,
    this.onTapDataPoint,
  }) : super(key: key);

  @override
  State<IndicatorChart> createState() => _IndicatorChartState();
}

class _IndicatorChartState extends State<IndicatorChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return _buildEmptyState();
    }

    final spots = _buildSpots();
    final minY = _getMinY();
    final maxY = _getMaxY();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.indicatorLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_touchedIndex != null) ...[
                  Text(
                    _buildTooltipText(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: widget.chartColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),

            // グラフ領域
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (maxY - minY) / 5,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              _formatAxisValue(value),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                        reservedSize: 50,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= widget.history.length) {
                            return const Text('');
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              'Y${widget.history[index].year}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: widget.chartColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final isSelected = index == _touchedIndex;
                          return FlDotCirclePainter(
                            radius: isSelected ? 6 : 4,
                            color: isSelected
                                ? widget.chartColor
                                : widget.chartColor.withValues(alpha: 0.7),
                            strokeWidth: isSelected ? 2 : 0,
                            strokeColor: widget.chartColor,
                          );
                        },
                      ),
                      preventCurveOvershootingThreshold: 10,
                    ),
                  ],
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.grey.withValues(alpha: 0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${_formatValue(spot.y)}${widget.unit}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    touchCallback: (event, response) {
                      setState(() {
                        if (response != null &&
                            response.lineBarSpots != null &&
                            response.lineBarSpots!.isNotEmpty) {
                          final index = response.lineBarSpots![0].x.toInt();
                          if (index >= 0 && index < widget.history.length) {
                            _touchedIndex = index;
                            widget.onTapDataPoint?.call(widget.history[index]);
                          }
                        } else {
                          _touchedIndex = null;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),

            // 統計情報
            _buildStats(),
          ],
        ),
      ),
    );
  }

  /// 空の状態を表示。
  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Center(
          child: Text(
            'まだデータがありません',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ),
    );
  }

  /// グラフ用のスポット（座標）を生成。
  List<FlSpot> _buildSpots() {
    return List.generate(
      widget.history.length,
      (index) {
        final value = _getIndicatorValue(widget.history[index]);
        return FlSpot(index.toDouble(), value);
      },
    );
  }

  /// 最小Y値を計算（下限マージンを加算）。
  double _getMinY() {
    final values = widget.history
        .map((snapshot) => _getIndicatorValue(snapshot))
        .toList();
    if (values.isEmpty) return 0;
    final min = values.reduce((a, b) => a < b ? a : b);
    return (min - 10).clamp(0, double.infinity);
  }

  /// 最大Y値を計算（上限マージンを加算）。
  double _getMaxY() {
    final values = widget.history
        .map((snapshot) => _getIndicatorValue(snapshot))
        .toList();
    if (values.isEmpty) return 100;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max + 10;
  }

  /// スナップショットから指定の指標値を抽出。
  double _getIndicatorValue(IndicatorSnapshot snapshot) {
    switch (widget.indicatorKey) {
      case 'gdp':
        return snapshot.gdp;
      case 'unemployment':
        return snapshot.unemployment;
      case 'satisfaction':
        return snapshot.satisfaction;
      case 'nationalPower':
        return snapshot.nationalPower;
      case 'inflationRate':
        return snapshot.inflationRate;
      case 'publicDebt':
        return snapshot.publicDebt;
      case 'stability':
        return snapshot.stability;
      default:
        return 0;
    }
  }

  /// ツールチップ表示用テキストを生成。
  String _buildTooltipText() {
    if (_touchedIndex == null || _touchedIndex! >= widget.history.length) {
      return '';
    }
    final snapshot = widget.history[_touchedIndex!];
    final value = _getIndicatorValue(snapshot);
    final formatted = _formatValue(value);
    return 'Y${snapshot.year}: $formatted${widget.unit}';
  }

  /// 統計情報パネルを構築。
  Widget _buildStats() {
    final values = widget.history
        .map((snapshot) => _getIndicatorValue(snapshot))
        .toList();

    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final current = values.last;
    final previous = values.length > 1 ? values[values.length - 2] : current;
    final change = current - previous;
    final changePercent = previous != 0 ? (change / previous * 100) : 0;

    final isPositive = change >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '現在値',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '${_formatValue(current)}${widget.unit}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '前年比',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '${isPositive ? '+' : ''}${_formatValue(change)}${widget.unit} '
              '(${_formatValue(changePercent)}%)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  /// 値をフォーマット（小数第1位まで）。
  String _formatValue(double value) {
    return value.toStringAsFixed(1);
  }

  /// 軸ラベルをフォーマット。
  String _formatAxisValue(double value) {
    if (widget.indicatorKey == 'gdp') {
      return '\$${value.toStringAsFixed(0)}B';
    }
    return value.toStringAsFixed(0);
  }
}
